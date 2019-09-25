# =========================================================
# Locals
# =========================================================

locals {
    name_prefix = var.name_prefix == null ? "${var.project}-" : var.name_prefix
}
