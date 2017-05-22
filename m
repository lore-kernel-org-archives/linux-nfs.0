Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53940 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935695AbdEVQWm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 May 2017 12:22:42 -0400
Subject: [PATCH 1/9] containers: Rename linux/container.h to
 linux/container_dev.h
From: David Howells <dhowells@redhat.com>
To: trondmy@primarydata.com
Cc: mszeredi@redhat.com, linux-nfs@vger.kernel.org, jlayton@redhat.com,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org, ebiederm@xmission.com
Date: Mon, 22 May 2017 17:22:34 +0100
Message-ID: <149547015467.10599.4544567025423488374.stgit@warthog.procyon.org.uk>
In-Reply-To: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
References: <149547014649.10599.12025037906646164347.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rename linux/container.h to linux/container_dev.h so that linux/container.h
can be used for containers.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/acpi/container.c      |    2 +-
 drivers/base/container.c      |    2 +-
 include/linux/container.h     |   25 -------------------------
 include/linux/container_dev.h |   25 +++++++++++++++++++++++++
 4 files changed, 27 insertions(+), 27 deletions(-)
 delete mode 100644 include/linux/container.h
 create mode 100644 include/linux/container_dev.h

diff --git a/drivers/acpi/container.c b/drivers/acpi/container.c
index 12c240903c18..435db0694405 100644
--- a/drivers/acpi/container.c
+++ b/drivers/acpi/container.c
@@ -23,7 +23,7 @@
  * ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  */
 #include <linux/acpi.h>
-#include <linux/container.h>
+#include <linux/container_dev.h>
 
 #include "internal.h"
 
diff --git a/drivers/base/container.c b/drivers/base/container.c
index ecbfbe2e908f..003bf5634f6b 100644
--- a/drivers/base/container.c
+++ b/drivers/base/container.c
@@ -9,7 +9,7 @@
  * published by the Free Software Foundation.
  */
 
-#include <linux/container.h>
+#include <linux/container_dev.h>
 
 #include "base.h"
 
diff --git a/include/linux/container.h b/include/linux/container.h
deleted file mode 100644
index 3c03e6fd2035..000000000000
--- a/include/linux/container.h
+++ /dev/null
@@ -1,25 +0,0 @@
-/*
- * Definitions for container bus type.
- *
- * Copyright (C) 2013, Intel Corporation
- * Author: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-#include <linux/device.h>
-
-/* drivers/base/power/container.c */
-extern struct bus_type container_subsys;
-
-struct container_dev {
-	struct device dev;
-	int (*offline)(struct container_dev *cdev);
-};
-
-static inline struct container_dev *to_container_dev(struct device *dev)
-{
-	return container_of(dev, struct container_dev, dev);
-}
diff --git a/include/linux/container_dev.h b/include/linux/container_dev.h
new file mode 100644
index 000000000000..3c03e6fd2035
--- /dev/null
+++ b/include/linux/container_dev.h
@@ -0,0 +1,25 @@
+/*
+ * Definitions for container bus type.
+ *
+ * Copyright (C) 2013, Intel Corporation
+ * Author: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/device.h>
+
+/* drivers/base/power/container.c */
+extern struct bus_type container_subsys;
+
+struct container_dev {
+	struct device dev;
+	int (*offline)(struct container_dev *cdev);
+};
+
+static inline struct container_dev *to_container_dev(struct device *dev)
+{
+	return container_of(dev, struct container_dev, dev);
+}

