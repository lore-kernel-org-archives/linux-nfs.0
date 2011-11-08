Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29036 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932178Ab1KHLNY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Nov 2011 06:13:24 -0500
Subject: [PATCH v2 1/7] SUNRPC: create RPC pipefs superblock per network
	namespace context
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 08 Nov 2011 15:12:20 +0300
Message-ID: <20111108111220.6206.42087.stgit@localhost6.localdomain6>
In-Reply-To: <20111108111056.6206.11410.stgit@localhost6.localdomain6>
References: <20111108111056.6206.11410.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the initial step of RPC pipefs virtualization. It changes nothing to
current pipefs behaviour except that mount of pipefs in other than init_net
network namespace context will provide only root tree. No other dentries will
be visible.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpc_pipe.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index e2f7b7f..bb8a40b 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -994,6 +994,7 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 {
 	struct inode *inode;
 	struct dentry *root;
+	struct net *net = data;
 
 	sb->s_blocksize = PAGE_CACHE_SIZE;
 	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
@@ -1018,7 +1019,7 @@ static struct dentry *
 rpc_mount(struct file_system_type *fs_type,
 		int flags, const char *dev_name, void *data)
 {
-	return mount_single(fs_type, flags, data, rpc_fill_super);
+	return mount_ns(fs_type, flags, current->nsproxy->net_ns, rpc_fill_super);
 }
 
 static struct file_system_type rpc_pipe_fs_type = {

