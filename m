From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] rename svc_get/putlong as svc_get/putu32
Date: Wed, 18 Sep 2002 12:58:56 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0209181256470.1495-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
   Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17riAK-0003aU-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Sep 2002 09:59:04 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

hi Linus-

this patch, against 2.5.36, renames the svc_getlong and svc_putlong macros
as svc_getu32 and svc_putu32.  this is simple clean up and is obviously
correct.  it was part of the patch that implements stricter type checking
for rpc auth flavors.


diff -drN -U2 04-authflav/fs/nfsd/nfscache.c 05-svcgetput/fs/nfsd/nfscache.c
--- 04-authflav/fs/nfsd/nfscache.c	Wed Sep 18 11:45:54 2002
+++ 05-svcgetput/fs/nfsd/nfscache.c	Wed Sep 18 10:05:34 2002
@@ -273,5 +273,5 @@
 		break;
 	case RC_REPLSTAT:
-		svc_putlong(&rqstp->rq_resbuf, rp->c_replstat);
+		svc_putu32(&rqstp->rq_resbuf, rp->c_replstat);
 		rtn = RC_REPLY;
 		break;
diff -drN -U2 04-authflav/fs/nfsd/nfssvc.c 05-svcgetput/fs/nfsd/nfssvc.c
--- 04-authflav/fs/nfsd/nfssvc.c	Wed Sep 18 11:54:24 2002
+++ 05-svcgetput/fs/nfsd/nfssvc.c	Wed Sep 18 10:05:34 2002
@@ -303,5 +303,5 @@
 		
 	if (rqstp->rq_proc != 0)
-		svc_putlong(&rqstp->rq_resbuf, nfserr);
+		svc_putu32(&rqstp->rq_resbuf, nfserr);
 
 	/* Encode result.
diff -drN -U2 04-authflav/include/linux/sunrpc/svc.h 05-svcgetput/include/linux/sunrpc/svc.h
--- 04-authflav/include/linux/sunrpc/svc.h	Wed Sep 18 11:55:02 2002
+++ 05-svcgetput/include/linux/sunrpc/svc.h	Wed Sep 18 10:05:34 2002
@@ -83,6 +83,6 @@
 	int			nriov;
 };
-#define svc_getlong(argp, val)	{ (val) = *(argp)->buf++; (argp)->len--; }
-#define svc_putlong(resp, val)	{ *(resp)->buf++ = (val); (resp)->len++; }
+#define svc_getu32(argp, val)	{ (val) = *(argp)->buf++; (argp)->len--; }
+#define svc_putu32(resp, val)	{ *(resp)->buf++ = (val); (resp)->len++; }
 
 /*
diff -drN -U2 04-authflav/net/sunrpc/svc.c 05-svcgetput/net/sunrpc/svc.c
--- 04-authflav/net/sunrpc/svc.c	Wed Sep 18 11:56:09 2002
+++ 05-svcgetput/net/sunrpc/svc.c	Wed Sep 18 10:05:34 2002
@@ -248,6 +248,6 @@
 
 	/* First words of reply: */
-	svc_putlong(resp, xdr_one);		/* REPLY */
-	svc_putlong(resp, xdr_zero);		/* ACCEPT */
+	svc_putu32(resp, xdr_one);		/* REPLY */
+	svc_putu32(resp, xdr_zero);		/* ACCEPT */
 
 	if (dir != 0)		/* direction != CALL */
@@ -301,5 +301,5 @@
 	/* Build the reply header. */
 	statp = resp->buf;
-	svc_putlong(resp, rpc_success);		/* RPC_SUCCESS */
+	svc_putu32(resp, rpc_success);		/* RPC_SUCCESS */
 
 	/* Bump per-procedure stats counter */
@@ -372,7 +372,7 @@
 	serv->sv_stats->rpcbadfmt++;
 	resp->buf[-1] = xdr_one;	/* REJECT */
-	svc_putlong(resp, xdr_zero);	/* RPC_MISMATCH */
-	svc_putlong(resp, xdr_two);	/* Only RPCv2 supported */
-	svc_putlong(resp, xdr_two);
+	svc_putu32(resp, xdr_zero);	/* RPC_MISMATCH */
+	svc_putu32(resp, xdr_two);	/* Only RPCv2 supported */
+	svc_putu32(resp, xdr_two);
 	goto sendit;
 
@@ -381,6 +381,6 @@
 	serv->sv_stats->rpcbadauth++;
 	resp->buf[-1] = xdr_one;	/* REJECT */
-	svc_putlong(resp, xdr_one);	/* AUTH_ERROR */
-	svc_putlong(resp, auth_stat);	/* status */
+	svc_putu32(resp, xdr_one);	/* AUTH_ERROR */
+	svc_putu32(resp, auth_stat);	/* status */
 	goto sendit;
 
@@ -392,5 +392,5 @@
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putlong(resp, rpc_prog_unavail);
+	svc_putu32(resp, rpc_prog_unavail);
 	goto sendit;
 
@@ -400,7 +400,7 @@
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putlong(resp, rpc_prog_mismatch);
-	svc_putlong(resp, htonl(progp->pg_lovers));
-	svc_putlong(resp, htonl(progp->pg_hivers));
+	svc_putu32(resp, rpc_prog_mismatch);
+	svc_putu32(resp, htonl(progp->pg_lovers));
+	svc_putu32(resp, htonl(progp->pg_hivers));
 	goto sendit;
 
@@ -410,5 +410,5 @@
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putlong(resp, rpc_proc_unavail);
+	svc_putu32(resp, rpc_proc_unavail);
 	goto sendit;
 
@@ -418,5 +418,5 @@
 #endif
 	serv->sv_stats->rpcbadfmt++;
-	svc_putlong(resp, rpc_garbage_args);
+	svc_putu32(resp, rpc_garbage_args);
 	goto sendit;
 }
diff -drN -U2 04-authflav/net/sunrpc/svcauth.c 05-svcgetput/net/sunrpc/svcauth.c
--- 04-authflav/net/sunrpc/svcauth.c	Wed Sep 18 11:57:39 2002
+++ 05-svcgetput/net/sunrpc/svcauth.c	Wed Sep 18 10:05:34 2002
@@ -49,5 +49,5 @@
 	*authp = rpc_auth_ok;
 
-	svc_getlong(&rqstp->rq_argbuf, flavor);
+	svc_getu32(&rqstp->rq_argbuf, flavor);
 	flavor = ntohl(flavor);
 
@@ -106,6 +106,6 @@
 	/* Put NULL verifier */
 	rqstp->rq_verfed = 1;
-	svc_putlong(resp, RPC_AUTH_NULL);
-	svc_putlong(resp, 0);
+	svc_putu32(resp, RPC_AUTH_NULL);
+	svc_putu32(resp, 0);
 }
 
@@ -153,6 +153,6 @@
 	/* Put NULL verifier */
 	rqstp->rq_verfed = 1;
-	svc_putlong(resp, RPC_AUTH_NULL);
-	svc_putlong(resp, 0);
+	svc_putu32(resp, RPC_AUTH_NULL);
+	svc_putu32(resp, 0);
 
 	return;
diff -drN -U2 04-authflav/net/sunrpc/svcsock.c 05-svcgetput/net/sunrpc/svcsock.c
--- 04-authflav/net/sunrpc/svcsock.c	Wed Sep 18 11:58:02 2002
+++ 05-svcgetput/net/sunrpc/svcsock.c	Wed Sep 18 10:05:34 2002
@@ -1092,6 +1092,6 @@
 	rqstp->rq_verfed  = 0;
 
-	svc_getlong(&rqstp->rq_argbuf, rqstp->rq_xid);
-	svc_putlong(&rqstp->rq_resbuf, rqstp->rq_xid);
+	svc_getu32(&rqstp->rq_argbuf, rqstp->rq_xid);
+	svc_putu32(&rqstp->rq_resbuf, rqstp->rq_xid);
 
 	/* Assume that the reply consists of a single buffer. */

-- 

corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>





-------------------------------------------------------
This SF.NET email is sponsored by: AMD - Your access to the experts
on Hammer Technology! Open Source & Linux Developers, register now
for the AMD Developer Symposium. Code: EX8664
http://www.developwithamd.com/developerlab
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
