Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:45378 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752603AbdKHPAU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 10:00:20 -0500
Received: by mail-io0-f194.google.com with SMTP id i38so6225851iod.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Nov 2017 07:00:20 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC 2/4] SUNRPC: Kill client tasks from debugfs
Date: Wed,  8 Nov 2017 08:59:40 -0600
Message-Id: <20171108145942.5127-3-JPEWhacker@gmail.com>
In-Reply-To: <20171108145942.5127-1-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
 <20171108145942.5127-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "kill" client entry in debugfs can be used to kill client tasks.
Writing "0" causes only the currently pending tasks to be killed, while
writing "1" all currently pending, and any future pending tasks to be
killed.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 net/sunrpc/debugfs.c | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 48 insertions(+)

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index e980d2a493de..a2f33d168873 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -118,6 +118,50 @@ static const struct file_operations tasks_fops = {
 	.release	= tasks_release,
 };
 
+static int
+kill_set(void *data, u64 val)
+{
+	struct rpc_clnt *clnt = data;
+
+	rpc_killall_tasks(clnt, (int)val);
+	return 0;
+}
+
+static int
+kill_open(struct inode *inode, struct file *filp)
+{
+	int ret = simple_attr_open(inode, filp, NULL, kill_set, "%i");
+
+	if (!ret) {
+		struct rpc_clnt *clnt = inode->i_private;
+
+		if (!atomic_inc_not_zero(&clnt->cl_count)) {
+			simple_attr_release(inode, filp);
+			ret = -EINVAL;
+		}
+	}
+
+	return ret;
+}
+
+static int
+kill_release(struct inode *inode, struct file *filp)
+{
+	struct rpc_clnt *clnt = inode->i_private;
+
+	rpc_release_client(clnt);
+
+	return simple_attr_release(inode, filp);
+}
+
+static const struct file_operations kill_fops = {
+	.owner	 = THIS_MODULE,
+	.open	 = kill_open,
+	.release = kill_release,
+	.write	 = debugfs_attr_write,
+	.llseek  = no_llseek,
+};
+
 void
 rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 {
@@ -160,6 +204,10 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs, name))
 		goto out_err;
 
+	if (!debugfs_create_file("kill", S_IFREG | 0200, clnt->cl_debugfs,
+				 clnt, &kill_fops))
+		goto out_err;
+
 	return;
 out_err:
 	debugfs_remove_recursive(clnt->cl_debugfs);
-- 
2.13.6

