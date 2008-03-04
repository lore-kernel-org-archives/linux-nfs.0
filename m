From: NeilBrown <neilb@suse.de>
Subject: [PATCH] Add more entropy to selection of port and xid for NFS client.
Date: Tue, 4 Mar 2008 16:35:53 +1100
Message-ID: <1080304053553.18549@suse.de>
References: <20080304163343.18442.patches@notabene>
Cc: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:41173 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750842AbYCDFgB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Mar 2008 00:36:01 -0500
Cc: linux-nfs@vger.kernel.org
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond/Chunk

I wonder what you think of this patch.

I found we needed it for some customers who had machines with NFS root
who (for reasons I never fully understood) find they reboot their
machines fairly often (maybe it was a test setup or something).  The
often got "inode number mismatch" errors because the reply came out of
the server's cache and was left over from before the client's reboot.

Thanks,
NeilBrown


### Comments for Changeset

Diskless clients that use NFS-root have very little chance
to gain much entropy in net_random before the NFS client must
choose a port number and an 'xid' to being talking to the server.
So add as much entropy as possible.

Without this, clients can and do suffer from collisions in the servers
reply cache, and get meaningless replies.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/xprt.c     |    5 ++++-
 ./net/sunrpc/xprtsock.c |    7 +++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

diff .prev/net/sunrpc/xprt.c ./net/sunrpc/xprt.c
--- .prev/net/sunrpc/xprt.c	2008-03-04 16:33:26.000000000 +1100
+++ ./net/sunrpc/xprt.c	2008-03-04 16:33:36.000000000 +1100
@@ -922,7 +922,10 @@ static inline __be32 xprt_alloc_xid(stru
 
 static inline void xprt_init_xid(struct rpc_xprt *xprt)
 {
-	xprt->xid = net_random();
+	get_random_bytes(&xprt->xid, sizeof(xprt->xid));
+	/* And just in case random_state isn't initialised yet.. */
+	xprt->xid ^= net_random();
+	xprt->xid += (CURRENT_TIME.tv_sec << 10);
 }
 
 static void xprt_request_init(struct rpc_task *task, struct rpc_xprt *xprt)

diff .prev/net/sunrpc/xprtsock.c ./net/sunrpc/xprtsock.c
--- .prev/net/sunrpc/xprtsock.c	2008-03-04 16:33:26.000000000 +1100
+++ ./net/sunrpc/xprtsock.c	2008-03-04 16:28:06.000000000 +1100
@@ -1283,8 +1283,11 @@ static void xs_udp_timer(struct rpc_task
 static unsigned short xs_get_random_port(void)
 {
 	unsigned short range = xprt_max_resvport - xprt_min_resvport;
-	unsigned short rand = (unsigned short) net_random() % range;
-	return rand + xprt_min_resvport;
+	unsigned short rand;
+	get_random_bytes(&rand, sizeof(rand));
+	rand ^= (unsigned short)net_random();
+	rand ^= (CURRENT_TIME.tv_nsec >> 10);
+	return (rand % range) + xprt_min_resvport;
 }
 
 /**
