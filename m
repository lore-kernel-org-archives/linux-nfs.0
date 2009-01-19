From: Greg Banks <gnb@sgi.com>
Subject: [patch 5/5] Add a (not built) module to test the dprintk module.
Date: Mon, 19 Jan 2009 17:40:23 +1100
Message-ID: <20090119064912.595383000@sgi.com>
References: <20090119064018.442220000@sgi.com>
Cc: "Frank Ch. Eigler" <fche@redhat.com>
To: Linux NFS ML <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:57093 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753291AbZASGtY (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Mon, 19 Jan 2009 01:49:24 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Not to be applied, test code only.

Signed-off-by: Greg Banks <gnb@sgi.com>
---

 kernel/Makefile       |    3 +
 kernel/test-dprintk.c |   69 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)

Index: bfields/kernel/test-dprintk.c
===================================================================
--- /dev/null
+++ bfields/kernel/test-dprintk.c
@@ -0,0 +1,69 @@
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
+	pde = create_proc_entry("foobar", 0200, &proc_root);
+	if (pde != NULL)
+		pde->proc_fops = &exp_fops;
+
+	return 0;
+}
+
+static void __exit exp_cleanup(void)
+{
+	printk("exp_cleanup:\n");
+	remove_proc_entry("foobar", &proc_root);
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
@@ -91,6 +91,9 @@ obj-$(CONFIG_SMP) += sched_cpupri.o
 obj-$(CONFIG_SLOW_WORK) += slow-work.o
 obj-$(CONFIG_DPRINTK) += dprintk.o
 
+# Uncomment this to build a module for testing dprintk.ko
+# obj-m += test-dprintk.o
+
 ifneq ($(CONFIG_SCHED_OMIT_FRAME_POINTER),y)
 # According to Alan Modra <alan-HpYC8cTCicIJY7gZg3T8ig@public.gmane.org>, the -fno-omit-frame-pointer is
 # needed for x86 only.  Why this used to be enabled for all architectures is beyond

--
-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.
