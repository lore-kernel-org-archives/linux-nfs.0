From: Greg Banks <gnb@sgi.com>
Subject: [patch 1/5] Move definitions of struct module_sect_attr back into module.h.
Date: Mon, 19 Jan 2009 17:40:19 +1100
Message-ID: <20090119064911.738349000@sgi.com>
References: <20090119064018.442220000@sgi.com>
Cc: "Frank Ch. Eigler" <fche@redhat.com>
To: Linux NFS ML <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:58546 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752914AbZASGtT (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 01:49:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The new dprintk module needs to use module_sect_attr.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 include/linux/module.h |   15 +++++++++++++++
 kernel/module.c        |   13 -------------
 2 files changed, 15 insertions(+), 13 deletions(-)

Index: bfields/kernel/module.c
===================================================================
--- bfields.orig/kernel/module.c
+++ bfields/kernel/module.c
@@ -1088,19 +1101,6 @@ static unsigned long resolve_symbol(Elf_
  * J. Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
  */
 #if defined(CONFIG_KALLSYMS) && defined(CONFIG_SYSFS)
-struct module_sect_attr
-{
-	struct module_attribute mattr;
-	char *name;
-	unsigned long address;
-};
-
-struct module_sect_attrs
-{
-	struct attribute_group grp;
-	unsigned int nsections;
-	struct module_sect_attr attrs[0];
-};
 
 static ssize_t module_sect_show(struct module_attribute *mattr,
 				struct module *mod, char *buf)
Index: bfields/include/linux/module.h
===================================================================
--- bfields.orig/include/linux/module.h
+++ bfields/include/linux/module.h
@@ -231,6 +231,21 @@ enum module_state
 	MODULE_STATE_GOING,
 };
 
+struct module_sect_attr
+{
+	struct module_attribute mattr;
+	char *name;
+	unsigned long address;
+};
+
+struct module_sect_attrs
+{
+	struct attribute_group grp;
+	unsigned int nsections;
+	struct module_sect_attr attrs[0];
+};
+
+
 struct module
 {
 	enum module_state state;

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
