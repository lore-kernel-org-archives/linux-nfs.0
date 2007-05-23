From: Greg Banks <gnb@sgi.com>
Subject: [RFC,
	PATCH 2/5] knfsd: allow preserving of transport header across
	deferrals
Date: Thu, 24 May 2007 00:33:13 +1000
Message-ID: <20070523143313.GJ14076@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Thomas Talpey <Thomas.Talpey@netapp.com>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hqrts-00051d-DO
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:33:16 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+ECQjgJ47LLCKu87YFM6AvSvnfE4kN7b4=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hqrtv-0002BI-49
	for nfs@lists.sourceforge.net; Wed, 23 May 2007 07:33:19 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


Generic code allows transport-specific code to specify a number
of bytes of transport-specific header which needs to be preserved
across call deferral & revisit.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 include/linux/sunrpc/svc.h |    2 ++
 include/linux/sunrpc/xdr.h |    3 ++-
 net/sunrpc/svc.c           |    1 +
 net/sunrpc/svcsock.c       |    9 +++++++--
 4 files changed, 12 insertions(+), 3 deletions(-)

Index: linux/include/linux/sunrpc/svc.h
===================================================================
--- linux.orig/include/linux/sunrpc/svc.h	2007-04-26 13:08:32.000000000 +1000
+++ linux/include/linux/sunrpc/svc.h	2007-05-23 22:32:48.999813425 +1000
@@ -321,6 +321,8 @@ struct svc_deferred_req {
 	union svc_addr_u	daddr;	/* where reply must come from */
 	struct cache_deferred_req handle;
 	int			argslen;
+	int			trans_header;	/* size of preserved transport-
+						 * specific header */
 	__be32			args[0];
 };
 
Index: linux/include/linux/sunrpc/xdr.h
===================================================================
--- linux.orig/include/linux/sunrpc/xdr.h	2007-04-26 13:08:32.000000000 +1000
+++ linux/include/linux/sunrpc/xdr.h	2007-05-23 22:30:39.472325101 +1000
@@ -58,7 +58,8 @@ struct xdr_buf {
 
 	unsigned int	buflen,		/* Total length of storage buffer */
 			len;		/* Length of XDR encoded message */
-
+	unsigned int	trans_header;	/* Length of transport-specific
+					 * header in bytes */
 };
 
 /*
Index: linux/net/sunrpc/svc.c
===================================================================
--- linux.orig/net/sunrpc/svc.c	2007-05-23 21:38:28.000000000 +1000
+++ linux/net/sunrpc/svc.c	2007-05-23 22:31:14.379876126 +1000
@@ -813,6 +813,7 @@ svc_process(struct svc_rqst *rqstp)
 	rqstp->rq_res.buflen = PAGE_SIZE;
 	rqstp->rq_res.tail[0].iov_base = NULL;
 	rqstp->rq_res.tail[0].iov_len = 0;
+	rqstp->rq_res.trans_header = 0;
 	/* Will be turned off only in gss privacy case: */
 	rqstp->rq_sendfile_ok = 1;
 	if (rqstp->rq_sock->sk_type->st_prepare_reply &&
Index: linux/net/sunrpc/svcsock.c
===================================================================
--- linux.orig/net/sunrpc/svcsock.c	2007-05-23 21:40:00.000000000 +1000
+++ linux/net/sunrpc/svcsock.c	2007-05-23 22:39:53.501637503 +1000
@@ -1481,6 +1481,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	arg->page_len = (pages-2)*PAGE_SIZE;
 	arg->len = (pages-1)*PAGE_SIZE;
 	arg->tail[0].iov_len = 0;
+	arg->trans_header = 0;
 
 	try_to_freeze();
 	cond_resched();
@@ -2007,7 +2008,8 @@ static struct cache_deferred_req *
 svc_defer(struct cache_req *req)
 {
 	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
-	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len);
+	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_arg.len
+				    + rqstp->rq_arg.trans_header);
 	struct svc_deferred_req *dr;
 
 	if (rqstp->rq_arg.page_len)
@@ -2028,6 +2030,8 @@ svc_defer(struct cache_req *req)
 		dr->addrlen = rqstp->rq_addrlen;
 		dr->daddr = rqstp->rq_daddr;
 		dr->argslen = rqstp->rq_arg.len >> 2;
+		dr->trans_header = rqstp->rq_arg.trans_header;
+		skip += dr->trans_header;
 		memcpy(dr->args, rqstp->rq_arg.head[0].iov_base-skip, dr->argslen<<2);
 	}
 	svc_sock_get(rqstp->rq_sock);
@@ -2044,10 +2048,11 @@ static int svc_deferred_recv(struct svc_
 {
 	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
-	rqstp->rq_arg.head[0].iov_base = dr->args;
+	rqstp->rq_arg.head[0].iov_base = dr->args + dr->trans_header;
 	rqstp->rq_arg.head[0].iov_len = dr->argslen<<2;
 	rqstp->rq_arg.page_len = 0;
 	rqstp->rq_arg.len = dr->argslen<<2;
+	rqstp->rq_arg.trans_header = dr->trans_header;
 	rqstp->rq_prot        = dr->prot;
 	memcpy(&rqstp->rq_addr, &dr->addr, dr->addrlen);
 	rqstp->rq_addrlen     = dr->addrlen;
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
