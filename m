Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:58750 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751532Ab1CVDOc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Mar 2011 23:14:32 -0400
Message-ID: <4D881413.9050807@parallels.com>
Date: Mon, 21 Mar 2011 22:14:27 -0500
From: Rob Landley <rlandley@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tim Spriggs <tims@uahirise.org>
Subject: [PATCH] Minimal fix to mount NFS in containers with non-default network
 context.
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Rob Landley <rlandley@parallels.com>

Here is the first (simple) patch to get NFS working in a container that 
a different network context than init_net.  I've tested it with:

 mount -t nfs 10.0.2.2:/path/to/mnt tempdir \
    -o port=9999,mountport=9999,nolock,nosharecache,nfsvers=3

For a test server, I used unfs3.sourceforge.net:

  unfsd -d -s -p -l 10.0.2.2 -m 9999 -n 9999 \
    -e <(echo '/path/to/mnt (rw,no_root_squash,insecure)')

And my test environment setup is described in excruciating detail here:

  http://landley.net/lxc/

Both ro/rw and udp/tcp in the mount -o work for me.

This requires a lot of follow-up patches to fix DNS resolution, 
portmapper, the lock daemon, superblock merging, nontrivial 
authentication mechanisms, the entire can of worms that is NFSv4...
But this at least makes basic NFS mounts work for the trivial case.
(It will _not_ work if two different network contexts try to mount
the same IP address, due to malignant caching.  Working on it.)

This patch is sampling the mount process context three times, which 
isn't ideal but is the least intrusive thing I can do for a first 
pass.  I've traced through and confirmed as best I can that all three 
are only called from the mount process context.  (Remount seems to be a 
different code path, and if you remount from a different network 
context I'm not sure what _should_ happen, anyway.  Keep the old one,
I guess?)

(I'm working on a patch adds a network context to nfs_client and then 
drills that down to the various places that could use it, which is 
more than just these 3, but it's a lot more intrusive and can be done 
on top of this.  Also, the rpc code is already doing the get_net() and 
put_net() reference counting for lifetimes this way.  When I add it to 
nfs_client I'll have to get that right myself.)

Signed-off-by: Rob Landley <rlandley@parallels.com>
---

 fs/nfs/client.c     |    3 ++-
 fs/nfs/mount_clnt.c |    5 +++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 192f2f8..4fb94e9 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -39,6 +39,7 @@
 #include <net/ipv6.h>
 #include <linux/nfs_xdr.h>
 #include <linux/sunrpc/bc_xprt.h>
+#include <linux/user_namespace.h>
 
 #include <asm/system.h>
 
@@ -619,7 +620,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 {
 	struct rpc_clnt		*clnt = NULL;
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= current->nsproxy->net_ns,
 		.protocol	= clp->cl_proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
 		.addrsize	= clp->cl_addrlen,
diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index d4c2d6b..5564f64 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -14,6 +14,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/nfs_fs.h>
+#include <linux/user_namespace.h>
 #include "internal.h"
 
 #ifdef RPC_DEBUG
@@ -153,7 +156,7 @@ int nfs_mount(struct nfs_mount_request *info)
 		.rpc_resp	= &result,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= current->nsproxy->net_ns,
 		.protocol	= info->protocol,
 		.address	= info->sap,
 		.addrsize	= info->salen,
@@ -225,7 +228,7 @@ void nfs_umount(const struct nfs_mount_request *info)
 		.to_retries = 2,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= current->nsproxy->net_ns,
 		.protocol	= IPPROTO_UDP,
 		.address	= info->sap,
 		.addrsize	= info->salen,
