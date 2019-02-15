Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC699C10F02
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:07:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C6AEE21927
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 16:07:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2391340AbfBOQH3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 15 Feb 2019 11:07:29 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2391310AbfBOQH2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 15 Feb 2019 11:07:28 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 04EB3AB42C;
        Fri, 15 Feb 2019 16:07:28 +0000 (UTC)
Received: from warthog.procyon.org.uk (ovpn-121-129.rdu2.redhat.com [10.10.121.129])
        by smtp.corp.redhat.com (Postfix) with ESMTP id F13D619C65;
        Fri, 15 Feb 2019 16:07:23 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
 Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
 Kingdom.
 Registered in England and Wales under Company Registration No. 3798903
Subject: [RFC PATCH 01/27] containers: Rename linux/container.h to
 linux/container_dev.h
From:   David Howells <dhowells@redhat.com>
To:     keyrings@vger.kernel.org, trond.myklebust@hammerspace.com,
        sfrench@samba.org
Cc:     linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        rgb@redhat.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
Date:   Fri, 15 Feb 2019 16:07:23 +0000
Message-ID: <155024684311.21651.6261046862181321227.stgit@warthog.procyon.org.uk>
In-Reply-To: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
References: <155024683432.21651.14153938339749694146.stgit@warthog.procyon.org.uk>
User-Agent: StGit/unknown-version
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Fri, 15 Feb 2019 16:07:28 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

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
index 1ba42d2d3532..1ff01ead2b2a 100644
--- a/drivers/base/container.c
+++ b/drivers/base/container.c
@@ -6,7 +6,7 @@
  * Author: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
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

