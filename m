From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 0/35] nfsd41-for-2.6.30 patches
Date: Fri, 03 Apr 2009 08:08:58 +0300
Message-ID: <49D599EA.6060705@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andy Adamson <andros@netapp.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:28693 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758745AbZDCFJH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:09:07 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The v3 series contains all non-backchannel patches in our nfsd41
series that were reordered before the bc ones.
All the review cleanups received so far are squashed in
plus a few minor ones I made along the way, like eradicating
CONFIG_NFSD_V4_1. These should have zero functional affect
(please see diff at the end).

The series is available at
git://linux-nfs.org/~bhalevy/linux-pnfs.git nfsd41-for-2.6.30

The full series, including backchannel is under the nfsd41 branch
(old nfsd41 branch renamed nfsd41-all as it's inline with all other
-all branches)

Note that the nfs41 client patches for 2.6.30 are organized in
a similar way.  nfs41-for-2.6.30 contains all non-backchannel
and nfs41 follows with the rest

Benny

[PATCH v3 01/35] nfsd: don't use the deferral service, return NFS4ERR_DELAY
[PATCH v3 02/35] nfs41: common protocol definitions
[PATCH v3 03/35] nfsd41: define nfs41 error codes
[PATCH v3 04/35] nfsd41: sessions basic data types
[PATCH v3 05/35] nfsd41: introduce nfs4_client cl_sessions list
[PATCH v3 06/35] nfsd41: release_session when client is expired
[PATCH v3 07/35] nfsd41: sessionid hashing
[PATCH v3 08/35] nfsd41: xdr infrastructure
[PATCH v3 09/35] nfsd41: proc stubs
[PATCH v3 10/35] nfsd41: exchange_id operation
[PATCH v3 11/35] nfsd41: match clientid establishment method
[PATCH v3 12/35] nfsd41: sequence operation
[PATCH v3 13/35] nfsd41: enforce NFS4ERR_SEQUENCE_POS operation order rules for minorversion != 0 only.
[PATCH v3 14/35] nfsd41: DRC save, restore, and clear functions
[PATCH v3 15/35] nfsd41: hard page limit for DRC
[PATCH v3 16/35] nfsd41: nfsd DRC logic
[PATCH v3 17/35] nfsd41: clear DRC cache on free_session
[PATCH v3 18/35] nfsd41: create_session operation
[PATCH v3 19/35] nfsd41: Add a create session replay cache
[PATCH v3 20/35] nfsd41: non-page DRC for solo sequence responses
[PATCH v3 21/35] nfsd41: destroy_session operation
[PATCH v3 22/35] nfsd: pass nfsd4_compound_state* to nfs4_preprocess_{state,seq}id_op
[PATCH v3 23/35] nfsd41: stateid handling
[PATCH v3 24/35] nfsd41: check encode size for sessions maxresponse cached
[PATCH v3 25/35] nfsd41: clientid handling
[PATCH v3 26/35] nfsd41: access_valid
[PATCH v3 27/35] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
[PATCH v3 28/35] nfsd41: control nfsv4.1 svc via /proc/fs/nfsd/versions
[PATCH v3 29/35] nfsd41: provide support for minor version 1 at rpc level
[PATCH v3 30/35] nfsd41: pass writable attrs mask to nfsd4_decode_fattr
[PATCH v3 31/35] nfsd: dynamically skip encoded fattr bitmap in _nfsd4_verify
[PATCH v3 32/35] nfsd41: support for 3-word long attribute bitmask
[PATCH v3 33/35] nfsd41: SUPPATTR_EXCLCREAT attribute
[PATCH v3 34/35] nfsd41: CREATE_EXCLUSIVE4_1
[PATCH v3 35/35] nfsd41: Documentation/filesystems/nfs41-server.txt

git diff --stat -p nfsd41-for-2.6.30-2009-04-03-1 nfsd41
 include/linux/nfsd/nfsd.h |    6 +++---
 net/sunrpc/svcsock.c      |   15 ---------------
 net/sunrpc/xprtsock.c     |    8 --------
 3 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 5494dcd..0ec4d14 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -333,6 +333,9 @@ extern struct timeval	nfssvc_boot;
 #define NFSD_LEASE_TIME                 (nfs4_lease_time())
 #define NFSD_LAUNDROMAT_MINTIMEOUT      10   /* seconds */
 
+/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
+#define NFSD_DRC_SIZE_SHIFT	7
+
 /*
  * The following attributes are currently not supported by the NFSv4 server:
  *    ARCHIVE       (deprecated anyway)
@@ -374,9 +377,6 @@ extern struct timeval	nfssvc_boot;
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
 
-/* The percent of nr_free_buffer_pages used by the V4.1 server DRC */
-#define NFSD_DRC_SIZE_SHIFT	7
-
 static inline u32 nfsd_suppattrs0(u32 minorversion)
 {
 	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD0
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 90b2232..9d4e121 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -791,9 +791,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	int		len;
 	struct kvec *vec;
 	int pnum, vlen;
-#if defined(CONFIG_NFSD_V4_1)
 	struct rpc_rqst *req = NULL;
-#endif
 
 	dprintk("svc: tcp_recv %p data %d conn %d close %d\n",
 		svsk, test_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags),
@@ -886,7 +884,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		xid = *p++;
 		calldir = *p;
 
-#if defined(CONFIG_NFSD_V4_1)
 		if (calldir) {
 			/* REPLY */
 			if (svsk->sk_bc_xprt)
@@ -909,9 +906,6 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if (!calldir || !req)
 			vec[0] = rqstp->rq_arg.head[0];
 
-#else /* CONFIG_NFSD_V4_1 */
-		vec[0] = rqstp->rq_arg.head[0];
-#endif /* CONFIG_NFSD_V4_1 */
 		vec[0].iov_base += 8;
 		vec[0].iov_len -= 8;
 		len = svsk->sk_reclen - 8;
@@ -920,13 +914,9 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 
 	pnum = 1;
 	while (vlen < len) {
-#if defined(CONFIG_NFSD_V4_1)
 		vec[pnum].iov_base = (req) ?
 			page_address(req->rq_private_buf.pages[pnum - 1]) :
 			page_address(rqstp->rq_pages[pnum]);
-#else /* CONFIG_NFSD_V4_1 */
-		vec[pnum].iov_base = page_address(rqstp->rq_pages[pnum]);
-#endif /* CONFIG_NFSD_V4_1 */
 		vec[pnum].iov_len = PAGE_SIZE;
 		pnum++;
 		vlen += PAGE_SIZE;
@@ -943,13 +933,11 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	 */
 	len += 8;
 
-#if defined(CONFIG_NFSD_V4_1)
 	if (req) {
 		xprt_complete_rqst(req->rq_task, len);
 		len = 0;
 		goto out;
 	}
-#endif /* CONFIG_NFSD_V4_1 */
 	dprintk("svc: TCP complete record (%d bytes)\n", len);
 	rqstp->rq_arg.len = len;
 	rqstp->rq_arg.page_base = 0;
@@ -963,10 +951,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_xprt_ctxt   = NULL;
 	rqstp->rq_prot	      = IPPROTO_TCP;
 
-#if defined(CONFIG_NFSD_V4_1)
 out:
-#endif /* CONFIG_NFSD_V4_1 */
-
 	/* Reset TCP read info */
 	svsk->sk_reclen = 0;
 	svsk->sk_tcplen = 0;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index f90c7c3..81842ae 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1885,7 +1885,6 @@ static void xs_tcp_print_stats(struct rpc_xprt *xprt, struct seq_file *seq)
 			xprt->stat.bklog_u);
 }
 
-#if defined(CONFIG_NFSD_V4_1)
 /*
  * The connect worker for the backchannel
  * This should never be called as we should never need to connect
@@ -2098,7 +2097,6 @@ static void bc_destroy(struct rpc_xprt *xprt)
 {
 	return;
 }
-#endif /* CONFIG_NFSD_V4_1 */
 
 static struct rpc_xprt_ops xs_udp_ops = {
 	.set_buffer_size	= xs_udp_set_buffer_size,
@@ -2133,7 +2131,6 @@ static struct rpc_xprt_ops xs_tcp_ops = {
 	.print_stats		= xs_tcp_print_stats,
 };
 
-#if defined(CONFIG_NFSD_V4_1)
 /*
  * The rpc_xprt_ops for the server backchannel
  */
@@ -2151,7 +2148,6 @@ static struct rpc_xprt_ops bc_tcp_ops = {
 	.destroy		= bc_destroy,
 	.print_stats		= xs_tcp_print_stats,
 };
-#endif /* CONFIG_NFSD_V4_1 */
 
 static struct rpc_xprt *xs_setup_xprt(struct xprt_create *args,
 				      unsigned int slot_table_size)
@@ -2285,7 +2281,6 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 	xprt->tsh_size = sizeof(rpc_fraghdr) / sizeof(u32);
 	xprt->max_payload = RPC_MAX_FRAGMENT_SIZE;
 
-#ifdef CONFIG_NFSD_V4_1
 	if (args->bc_sock) {
 		/* backchannel */
 		xprt_set_bound(xprt);
@@ -2309,7 +2304,6 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 
 		goto next;
 	}
-#endif /* CONFIG_NFSD_V4_1 */
 
 	switch (addr->sa_family) {
 	case AF_INET:
@@ -2332,9 +2326,7 @@ static struct rpc_xprt *xs_setup_tcp(struct xprt_create *args)
 
 	xprt->ops = &xs_tcp_ops;
 
-#ifdef CONFIG_NFSD_V4_1
 next:
-#endif /* CONFIG_NFSD_V4_1 */
 	xprt->timeout = &xs_tcp_default_timeout;
 
 	switch (addr->sa_family) {
