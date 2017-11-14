Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:54443 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756490AbdKNXGm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Nov 2017 18:06:42 -0500
Received: by mail-io0-f195.google.com with SMTP id w127so8804280iow.11
        for <linux-nfs@vger.kernel.org>; Tue, 14 Nov 2017 15:06:41 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v3 7/7] NFS: Control failed clients through debugfs
Date: Tue, 14 Nov 2017 17:06:31 -0600
Message-Id: <20171114230631.14682-8-JPEWhacker@gmail.com>
In-Reply-To: <20171114230631.14682-1-JPEWhacker@gmail.com>
References: <20171114230631.14682-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The "failed" debugfs entry can be used to get or set the failed status
of a nfs_client.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/debugfs.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 59 insertions(+)

diff --git a/fs/nfs/debugfs.c b/fs/nfs/debugfs.c
index 0195431427c2..7ccf04847660 100644
--- a/fs/nfs/debugfs.c
+++ b/fs/nfs/debugfs.c
@@ -80,6 +80,56 @@ nfs_server_debugfs_unregister(struct nfs_server *server)
 	server->debugfs = NULL;
 }
 
+static int
+client_failed_show(struct seq_file *f, void *private)
+{
+	struct nfs_client *client = f->private;
+
+	seq_printf(f, "%c", client->cl_failed ? 'Y' : 'N');
+	return 0;
+}
+
+static ssize_t
+client_failed_write(struct file *file, const char __user *user_buf,
+		    size_t count, loff_t *ppos)
+{
+	struct seq_file *seq = file->private_data;
+	struct nfs_client *client = seq->private;
+	char buf[32];
+	size_t buf_size;
+	bool failed;
+	int err;
+
+	buf_size = min(count, sizeof(buf) - 1);
+	if (copy_from_user(buf, user_buf, buf_size))
+		return -EFAULT;
+
+	buf[buf_size] = '\0';
+
+	err = strtobool(buf, &failed);
+	if (err)
+		return err;
+
+	nfs_client_failed(client, failed);
+
+	return count;
+}
+
+static int
+client_failed_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, client_failed_show, inode->i_private);
+}
+
+static const struct file_operations client_failed_fops = {
+	.owner = THIS_MODULE,
+	.open = client_failed_open,
+	.read = seq_read,
+	.write = client_failed_write,
+	.llseek = seq_lseek,
+	.release = single_release
+};
+
 void
 nfs_client_debugfs_register(struct nfs_client *client)
 {
@@ -99,6 +149,15 @@ nfs_client_debugfs_register(struct nfs_client *client)
 
 	link_rpc_client("rpc_client", client->cl_rpcclient,
 			client->cl_debugfs);
+
+	if (!debugfs_create_file("failed", 0600, client->cl_debugfs, client,
+				 &client_failed_fops))
+		goto out_error;
+
+	return;
+out_error:
+	debugfs_remove_recursive(client->cl_debugfs);
+	client->cl_debugfs = NULL;
 }
 
 void
-- 
2.13.6

