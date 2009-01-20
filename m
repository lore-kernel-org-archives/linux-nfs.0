From: Greg Banks <gnb@sgi.com>
Subject: [patch 1/5] Move definitions of struct module_sect_attr back into module.h.
Date: Tue, 20 Jan 2009 12:29:31 +1100
Message-ID: <20090120013258.215204000@sgi.com>
References: <20090120012930.020621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>,
	Linux NFSv4 ML <nfsv4@linux-nfs.org>,
	SystemTAP ML <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:42108 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752577AbZATBdH (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 20:33:07 -0500
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
