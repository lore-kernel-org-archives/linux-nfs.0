From: Greg Banks <gnb@sgi.com>
Subject: [patch 5/5] Add a module to test the dprintk module.
Date: Tue, 20 Jan 2009 12:29:35 +1100
Message-ID: <20090120013259.082769000@sgi.com>
References: <20090120012930.020621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>,
	Linux NFSv4 ML <nfsv4@linux-nfs.org>,
	SystemTAP ML <systemtap-R2MHTz/CkKAf7BdofF/totBPR1lH4CV8@public.gmane.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:42105 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752526AbZATBdH (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 20:33:07 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 init/Kconfig          |    8 ++++
 kernel/Makefile       |    1 
 kernel/test-dprintk.c |   67 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+)

Index: bfields/kernel/test-dprintk.c
===================================================================
--- /dev/null
+++ bfields/kernel/test-dprintk.c
@@ -0,0 +1,67 @@
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/proc_fs.h>
+#include <asm/uaccess.h>
+#include <linux/dprintk.h>
+
+int foo(int x)
+{
+	dprintk("foo: x=%d\n", x);
+	return x+42;
+}
+
+int bar(int x)
+{
+	dprintk("bar: x=%d\n", x);
+	return x-3;
+}
+
+static ssize_t exp_write(struct file *file, const char __user *ubuf,
+		         size_t len, loff_t *offp)
+{
+	char tmp[8];
+
+	if (*offp != 0 || len == 0)
+		return 0;
+	if (len > sizeof(tmp))
+		len = sizeof(tmp);
+
+	if (copy_from_user(tmp, ubuf, len))
+		return -EFAULT;
+
+	switch (tmp[0]) {
+	case 'f': foo(100); break;
+	case 'b': bar(100); break;
+	}
+
+	*offp += len;
+	return len;
+}
+
+static struct file_operations exp_fops = {
+	.write = exp_write,
+};
+
+static int __init exp_init(void)
+{
+	struct proc_dir_entry *pde;
+
+	printk("exp_init:\n");
+
+	pde = proc_create("foobar", 0200, NULL, &exp_fops);
+
+	return 0;
+}
+
+static void __exit exp_cleanup(void)
+{
+	printk("exp_cleanup:\n");
+	remove_proc_entry("foobar", NULL);
+}
+
+MODULE_LICENSE("GPL");
+module_init(exp_init);
+module_exit(exp_cleanup);
+
+/* vim:set ai sw=8 sts=8: */
Index: bfields/kernel/Makefile
===================================================================
--- bfields.orig/kernel/Makefile
+++ bfields/kernel/Makefile
@@ -90,6 +90,7 @@ obj-$(CONFIG_TRACING) += trace/
 obj-$(CONFIG_SMP) += sched_cpupri.o
 obj-$(CONFIG_SLOW_WORK) += slow-work.o
 obj-$(CONFIG_DPRINTK) += dprintk.o
+obj-$(CONFIG_DPRINTK_TEST) += test-dprintk.o
 
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan-HpYC8cTCicIJY7gZg3T8ig@public.gmane.org>, the -fno-omit-frame-pointer is
Index: bfields/init/Kconfig
===================================================================
--- bfields.orig/init/Kconfig
+++ bfields/init/Kconfig
@@ -849,6 +849,14 @@ config DPRINTK
 
 	    See Documentation/dprintk-howto.txt for more details.
 
+config DPRINTK_TEST
+	default n
+	depends on DPRINTK
+	tristate "Test module for the dprintk module"
+
+	help
+	    Enable this only if you are developing the dprintk module.
+
 endmenu		# General setup
 
 config HAVE_GENERIC_DMA_COHERENT

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
