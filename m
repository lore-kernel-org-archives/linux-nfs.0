From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Please pull NFS client fixes for kernel 2.6.26-pre9
Date: Tue, 08 Jul 2008 15:30:12 -0400
Message-ID: <1215545412.17304.6.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22709 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716AbYGHTag (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jul 2008 15:30:36 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "hotfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git hotfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/dir.c           |    2 +-
 net/sunrpc/rpcb_clnt.c |   23 +++++++++++------------
 2 files changed, 12 insertions(+), 13 deletions(-)

commit 803a9067e19714ea7b7da760fe92f0d53bfa6994
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jul 1 15:20:55 2008 -0400

    SUNRPC: Fix an rpcbind breakage for the case of IPv6 lookups
    
    Now that rpcb_next_version has been split into an IPv4 version and an IPv6
    version, we Oops when rpcb_call_async attempts to look up the IPv6-specific
    RPC procedure in rpcb_next_version.
    
    Fix the Oops simply by having rpcb_getport_async pass the correct RPC
    procedure as an argument.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 0d3a34b48c87a374b37d7a21a60d257d076484f3
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jul 7 12:18:52 2008 -0400

    SUNRPC: Fix a double-free in rpcbind
    
    It is wrong to be freeing up the rpcbind arguments if the call to
    rpcb_call_async() fails, since they should already have been freed up by
    rpcb_map_release().
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2aac05a91971fbd1bf6cbed78b8731eb7454b9b7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon Jul 7 13:26:10 2008 -0400

    NFS: Fix readdir cache invalidation
    
    invalidate_inode_pages2_range() takes page offset arguments, not byte
    ranges.
    
    Another thought is that individual pages might perhaps get evicted by VM
    pressure, in which case we might perhaps want to re-read not only the
    evicted page, but all subsequent pages too (in case the server returns
    more/less data per page so that the alignment of the next entry
    changes). We should therefore remove the condition that we only do this on
    page->index==0.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 58d43da..982a206 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -204,7 +204,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page *page)
 	 * Note: assumes we have exclusive access to this mapping either
 	 *	 through inode->i_mutex or some other mechanism.
 	 */
-	if (page->index == 0 && invalidate_inode_pages2_range(inode->i_mapping, PAGE_CACHE_SIZE, -1) < 0) {
+	if (invalidate_inode_pages2_range(inode->i_mapping, page->index + 1, -1) < 0) {
 		/* Should never happen */
 		nfs_zap_mapping(inode, inode->i_mapping);
 	}
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 0517967..e6fb21b 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -243,10 +243,10 @@ int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 }
 EXPORT_SYMBOL_GPL(rpcb_getport_sync);
 
-static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbind_args *map, int version)
+static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbind_args *map, struct rpc_procinfo *proc)
 {
 	struct rpc_message msg = {
-		.rpc_proc = rpcb_next_version[version].rpc_proc,
+		.rpc_proc = proc,
 		.rpc_argp = map,
 		.rpc_resp = &map->r_port,
 	};
@@ -271,6 +271,7 @@ static struct rpc_task *rpcb_call_async(struct rpc_clnt *rpcb_clnt, struct rpcbi
 void rpcb_getport_async(struct rpc_task *task)
 {
 	struct rpc_clnt *clnt = task->tk_client;
+	struct rpc_procinfo *proc;
 	u32 bind_version;
 	struct rpc_xprt *xprt = task->tk_xprt;
 	struct rpc_clnt	*rpcb_clnt;
@@ -280,7 +281,6 @@ void rpcb_getport_async(struct rpc_task *task)
 	struct sockaddr *sap = (struct sockaddr *)&addr;
 	size_t salen;
 	int status;
-	struct rpcb_info *info;
 
 	dprintk("RPC: %5u %s(%s, %u, %u, %d)\n",
 		task->tk_pid, __func__,
@@ -313,10 +313,12 @@ void rpcb_getport_async(struct rpc_task *task)
 	/* Don't ever use rpcbind v2 for AF_INET6 requests */
 	switch (sap->sa_family) {
 	case AF_INET:
-		info = rpcb_next_version;
+		proc = rpcb_next_version[xprt->bind_index].rpc_proc;
+		bind_version = rpcb_next_version[xprt->bind_index].rpc_vers;
 		break;
 	case AF_INET6:
-		info = rpcb_next_version6;
+		proc = rpcb_next_version6[xprt->bind_index].rpc_proc;
+		bind_version = rpcb_next_version6[xprt->bind_index].rpc_vers;
 		break;
 	default:
 		status = -EAFNOSUPPORT;
@@ -324,14 +326,13 @@ void rpcb_getport_async(struct rpc_task *task)
 				task->tk_pid, __func__);
 		goto bailout_nofree;
 	}
-	if (info[xprt->bind_index].rpc_proc == NULL) {
+	if (proc == NULL) {
 		xprt->bind_index = 0;
 		status = -EPFNOSUPPORT;
 		dprintk("RPC: %5u %s: no more getport versions available\n",
 			task->tk_pid, __func__);
 		goto bailout_nofree;
 	}
-	bind_version = info[xprt->bind_index].rpc_vers;
 
 	dprintk("RPC: %5u %s: trying rpcbind version %u\n",
 		task->tk_pid, __func__, bind_version);
@@ -361,22 +362,20 @@ void rpcb_getport_async(struct rpc_task *task)
 	map->r_addr = rpc_peeraddr2str(rpcb_clnt, RPC_DISPLAY_UNIVERSAL_ADDR);
 	map->r_owner = RPCB_OWNER_STRING;	/* ignored for GETADDR */
 
-	child = rpcb_call_async(rpcb_clnt, map, xprt->bind_index);
+	child = rpcb_call_async(rpcb_clnt, map, proc);
 	rpc_release_client(rpcb_clnt);
 	if (IS_ERR(child)) {
 		status = -EIO;
+		/* rpcb_map_release() has freed the arguments */
 		dprintk("RPC: %5u %s: rpc_run_task failed\n",
 			task->tk_pid, __func__);
-		goto bailout;
+		goto bailout_nofree;
 	}
 	rpc_put_task(child);
 
 	task->tk_xprt->stat.bind_count++;
 	return;
 
-bailout:
-	kfree(map);
-	xprt_put(xprt);
 bailout_nofree:
 	rpcb_wake_rpcbind_waiters(xprt, status);
 bailout_nowake:

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
