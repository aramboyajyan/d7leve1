<?php

/**
 * @file
 * Enables modules and site configuration for a custom site installation.
 *
 * Created by: Topsitemakers
 * http://www.topsitemakers.com/
 */

/**
 * Define minimum execution time required to operate.
 */
define('LEVEL1_DRUPAL_MINIMUM_MAX_EXECUTION_TIME', 60);

/**
 * Implements hook_install_tasks().
 */
function level1_install_tasks($install_state) {
  $tasks = array();
  $tasks['level1_task_add_menu_items'] = array(
    'type' => 'normal',
    'run' => INSTALL_TASK_RUN_IF_REACHED,
  );

  return $tasks;
}

/**
 * Add most used links.
 */
function level1_task_add_menu_items() {
  // Remove all default shortcut links because they are useless.
  $shortcut_links = db_select('menu_links', 'l')
    ->fields('l', array('mlid'))
    ->condition('menu_name', 'shortcut-set-1')
    ->execute()
    ->fetchAll();
  foreach ($shortcut_links as $shortcut_link) {
    menu_link_delete($shortcut_link->mlid);
  }
  // Configure the links we will add to other menus (main menu and shortcut).
  $links = array(
    // Home link in the main menu.
    array(
      'link_title' => st('Home'),
      'link_path'  => '<front>',
      'menu_name'  => 'main-menu',
      'weight'     => 0,
    ),
    array(
      'link_title' => st('PHP'),
      'link_path'  => 'devel/php',
      'menu_name'  => 'shortcut-set-1',
      'weight'     => 0,
    ),
    array(
      'link_title' => st('Variables'),
      'link_path'  => 'devel/variable',
      'menu_name'  => 'shortcut-set-1',
      'weight'     => 1,
    ),
  );
  // Save links.
  foreach ($links as $link) {
    menu_link_save($link);
  }

  // Update the menu router information.
  menu_rebuild();
}

/**
 * Implements hook_form_FORM_ID_alter() for install_configure_form().
 *
 * Allows the profile to alter the site configuration form.
 */
function level1_form_install_configure_form_alter(&$form, $form_state) {
  // Prepare some variables to be used as default values of the final form.
  $server_name = $_SERVER['SERVER_NAME'];
  // Check if there is a dot in the server name. This is aimed for local
  // development environments, for example if the site is running at localhost.
  // In order to create a valid email address, the '.com' is appended.
  // This is added just to make creating a new dev site faster.
  if (!strpos($server_name, '.')) {
    $server_name = $server_name . '.com';
  }

  // Pre-populate the site name with the server name.
  $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
  // Set the default admin email address to "admin@domain.com".
  $form['site_information']['site_mail']['#default_value'] = 'contact@' . $server_name;
  // Set the default admin username and email address.
  $form['admin_account']['account']['name']['#default_value'] = 'admin';
  $form['admin_account']['account']['mail']['#default_value'] = 'webmaster@' . $server_name;
  // Set default country to US.
  $form['server_settings']['site_default_country']['#default_value'] = 'US';
}

/**
 * Implements hook_install_tasks_alter().
 */
function level1_install_tasks_alter(&$tasks, $install_state){
  global $install_state;
  // Skip the language selection screen and set the language to English by
  // default.
  $tasks['install_select_locale']['display'] = FALSE;
  $tasks['install_select_locale']['run']     = INSTALL_TASK_SKIP;
  $install_state['parameters']['locale']     = 'en';
}
