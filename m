Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:56848 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752666AbeDSNdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 19 Apr 2018 09:33:37 -0400
Subject: [PATCH 21/24] net: Export get_proc_net() [ver #7]
From: David Howells <dhowells@redhat.com>
To: viro@zeniv.linux.org.uk
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        dhowells@redhat.com, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Date: Thu, 19 Apr 2018 14:33:35 +0100
Message-ID: <152414481524.23902.11586304669285812321.stgit@warthog.procyon.org.uk>
In-Reply-To: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
References: <152414466005.23902.12967974041384198114.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Export get_proc_net() so that write() routines attached to net-namespaced
proc files can find the network namespace that they're in.  Currently, this
is only accessible via seqfile routines.

This will permit AFS to have a separate cell database per-network namespace
and to manage each one independently of the others.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/proc/proc_net.c      |    3 ++-
 include/linux/proc_fs.h |    2 ++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index 1763f370489d..23d56146e38f 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -33,10 +33,11 @@ static inline struct net *PDE_NET(struct proc_dir_entry *pde)
 	return pde->parent->data;
 }
 
-static struct net *get_proc_net(const struct inode *inode)
+struct net *get_proc_net(const struct inode *inode)
 {
 	return maybe_get_net(PDE_NET(PDE(inode)));
 }
+EXPORT_SYMBOL_GPL(get_proc_net);
 
 int seq_open_net(struct inode *ino, struct file *f,
 		 const struct seq_operations *ops, int size)
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 928ef9e4d912..47a87121d30c 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -79,6 +79,8 @@ static inline struct proc_dir_entry *proc_net_mkdir(
 	return proc_mkdir_data(name, 0, parent, net);
 }
 
+extern struct net *get_proc_net(const struct inode *inode);
+
 struct ns_common;
 int open_related_ns(struct ns_common *ns,
 		   struct ns_common *(*get_ns)(struct ns_common *ns));

