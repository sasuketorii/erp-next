app_name = "jp_translation"
app_title = "Japanese Translation Enhancement"
app_publisher = "Sasuke Torii"
app_description = "Enhanced Japanese translations for ERPNext"
app_email = "support@example.com"
app_license = "MIT"

# Includes in <head>
# ------------------

# include js, css files in header of desk.html
# app_include_css = "/assets/jp_translation/css/jp_translation.css"
# app_include_js = "/assets/jp_translation/js/jp_translation.js"

# include js, css files in header of web template
# web_include_css = "/assets/jp_translation/css/jp_translation.css"
# web_include_js = "/assets/jp_translation/js/jp_translation.js"

# include custom scss in every website theme (without file extension ".scss")
# website_theme_scss = "jp_translation/public/scss/website"

# include js, css files in header of web form
# webform_include_js = {"doctype": "public/js/doctype.js"}
# webform_include_css = {"doctype": "public/css/doctype.css"}

# include js in page
# page_js = {"page" : "public/js/file.js"}

# include js in doctype views
# doctype_js = {"doctype" : "public/js/doctype.js"}
# doctype_list_js = {"doctype" : "public/js/doctype_list.js"}
# doctype_tree_js = {"doctype" : "public/js/doctype_tree.js"}
# doctype_calendar_js = {"doctype" : "public/js/doctype_calendar.js"}

# Svg Icons
# ------------------
# include app icons in desk
# app_include_icons = "jp_translation/public/icons.svg"

# Home Pages
# ----------

# application home page (will override Website Settings)
# home_page = "login"

# website user home page (by Role)
# role_home_page = {
#	"Role": "home_page"
# }

# Generators
# ----------

# automatically create page for each record of this doctype
# website_generators = ["Web Page"]

# Jinja
# ----------

# add methods and filters to jinja environment
# jinja = {
#	"methods": "jp_translation.utils.jinja_methods",
#	"filters": "jp_translation.utils.jinja_filters"
# }

# Installation
# ------------

# before_install = "jp_translation.install.before_install"
# after_install = "jp_translation.install.after_install"

# Uninstallation
# ------------

# before_uninstall = "jp_translation.uninstall.before_uninstall"
# after_uninstall = "jp_translation.uninstall.after_uninstall"

# Integration Setup
# ------------------
# To set up dependencies/integrations with other apps
# Name of the app being installed is passed as an argument

# before_app_install = "jp_translation.utils.before_app_install"
# after_app_install = "jp_translation.utils.after_app_install"

# Integration Cleanup
# -------------------
# To clean up dependencies/integrations with other apps
# Name of the app being uninstalled is passed as an argument

# before_app_uninstall = "jp_translation.utils.before_app_uninstall"
# after_app_uninstall = "jp_translation.utils.after_app_uninstall"

# Auto-update
# -----------
# Automatically update this app when a new version is available
# auto_update = True

# Testing
# -------

# before_tests = "jp_translation.install.before_tests"

# Overriding Methods
# ------------------------------
#
# override_whitelisted_methods = {
#	"frappe.desk.doctype.event.event.get_events": "jp_translation.event.get_events"
# }
#
# each overriding function accepts a `data` argument;
# generated from the base implementation of the doctype dashboard,
# along with any modifications made in other Frappe apps
# override_doctype_dashboards = {
#	"Task": "jp_translation.task.get_dashboard_data"
# }

# exempt linked doctypes from being automatically cancelled
#
# auto_cancel_exempted_doctypes = ["Auto Repeat"]

# Ignore links to specified DocTypes when deleting documents
# -----------------------------------------------------------

# ignore_links_on_delete = ["Communication", "ToDo"]

# Request Events
# ----------------
# before_request = ["jp_translation.utils.before_request"]
# after_request = ["jp_translation.utils.after_request"]

# Job Events
# ----------
# before_job = ["jp_translation.utils.before_job"]
# after_job = ["jp_translation.utils.after_job"]

# User Data Protection
# --------------------

# user_data_fields = [
#	{
#		"doctype": "{doctype_1}",
#		"filter_by": "{filter_by}",
#		"redact_fields": ["{field_1}", "{field_2}"],
#		"partial": 1,
#	},
#	{
#		"doctype": "{doctype_2}",
#		"filter_by": "{filter_by}",
#		"strict": False,
#	},
#	{
#		"doctype": "{doctype_3}",
#		"partial": 1,
#	}
# ]

# Authentication and authorization
# --------------------------------

# auth_hooks = [
#	"jp_translation.auth.validate"
# ]

# Automatically update python controller files with type annotations for DocTypes
# -------------------------------------------------------------------------------
# export_python_type_annotations = True

# default_log_clearing_doctypes = {
#	"Logging DocType Name": 30  # days to retain logs
# }

# Custom translation files
# -------------------------
# List of translation files to be included in the app
# translations = ["jp_translation/translations/ja.csv"]