Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:33107 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754605AbcLNCt0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Dec 2016 21:49:26 -0500
From: Jia He <hejianet@gmail.com>
To: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>,
        Serge Hallyn <serge@hallyn.com>,
        "David S. Miller" <davem@davemloft.net>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Mel Gorman <mgorman@techsingularity.net>,
        Kees Cook <keescook@chromium.org>, Hugh Dickins <hughd@google.com>,
        Daniel Bristot de Oliveira <bristot@redhat.com>,
        Daniel Cashman <dcashman@google.com>, Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jia He <hejianet@gmail.com>
Subject: [RESEND PATCH v4 1/2] sysctl: introduce new proc handler proc_dobool
Date: Wed, 14 Dec 2016 10:49:15 +0800
Message-Id: <1481683756-29276-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1481683756-29276-1-git-send-email-hejianet@gmail.com>
References: <1481683756-29276-1-git-send-email-hejianet@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is to let bool variable could be correctly displayed in
big/little endian sysctl procfs.
sizeof(bool) is arch dependent, proc_dobool should work in all
arches.

Suggested-by: Pan Xinhui <xinhui@linux.vnet.ibm.com>
Signed-off-by: Jia He <hejianet@gmail.com>
---
 include/linux/sysctl.h |  2 ++
 kernel/sysctl.c        | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index adf4e51..255a9c7 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -41,6 +41,8 @@ typedef int proc_handler (struct ctl_table *ctl, int write,
 
 extern int proc_dostring(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
+extern int proc_dobool(struct ctl_table *, int,
+			void __user *, size_t *, loff_t *);
 extern int proc_dointvec(struct ctl_table *, int,
 			 void __user *, size_t *, loff_t *);
 extern int proc_douintvec(struct ctl_table *, int,
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 706309f..69f93cd 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -2112,6 +2112,20 @@ static int proc_put_char(void __user **buf, size_t *size, char c)
 	return 0;
 }
 
+static int do_proc_dobool_conv(bool *negp, unsigned long *lvalp,
+				int *valp,
+				int write, void *data)
+{
+	if (write)
+		*(bool *)valp = *lvalp;
+	else {
+		int val = *(bool *)valp;
+
+		*lvalp = (unsigned long)val;
+	}
+	return 0;
+}
+
 static int do_proc_dointvec_conv(bool *negp, unsigned long *lvalp,
 				 int *valp,
 				 int write, void *data)
@@ -2258,6 +2272,26 @@ static int do_proc_dointvec(struct ctl_table *table, int write,
 }
 
 /**
+ * proc_dobool - read/write a bool
+ * @table: the sysctl table
+ * @write: %TRUE if this is a write to the sysctl file
+ * @buffer: the user buffer
+ * @lenp: the size of the user buffer
+ * @ppos: file position
+ *
+ * Reads/writes up to table->maxlen/sizeof(unsigned int) integer
+ * values from/to the user buffer, treated as an ASCII string.
+ *
+ * Returns 0 on success.
+ */
+int proc_dobool(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	return do_proc_dointvec(table, write, buffer, lenp, ppos,
+				do_proc_dobool_conv, NULL);
+}
+
+/**
  * proc_dointvec - read a vector of integers
  * @table: the sysctl table
  * @write: %TRUE if this is a write to the sysctl file
@@ -2941,6 +2975,7 @@ int proc_doulongvec_ms_jiffies_minmax(struct ctl_table *table, int write,
  * No sense putting this after each symbol definition, twice,
  * exception granted :-)
  */
+EXPORT_SYMBOL(proc_dobool);
 EXPORT_SYMBOL(proc_dointvec);
 EXPORT_SYMBOL(proc_douintvec);
 EXPORT_SYMBOL(proc_dointvec_jiffies);
-- 
2.5.5

