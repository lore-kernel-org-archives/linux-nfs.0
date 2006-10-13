From: Marc Eshel <eshel@almaden.ibm.com>
Subject: Re: NLM lock reclaim failure
Date: Thu, 12 Oct 2006 22:43:22 -0700
Message-ID: <452F277A.3060607@almaden.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GYFr1-0000Nk-AL
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 22:45:07 -0700
Received: from e2.ny.us.ibm.com ([32.97.182.142])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GYFr1-000178-QK
	for nfs@lists.sourceforge.net; Thu, 12 Oct 2006 22:45:08 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9D5ivjg004003
	for <nfs@lists.sourceforge.net>; Fri, 13 Oct 2006 01:44:57 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9D5iweF145056
	for <nfs@lists.sourceforge.net>; Fri, 13 Oct 2006 01:44:58 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9D5ivv8030744
	for <nfs@lists.sourceforge.net>; Fri, 13 Oct 2006 01:44:57 -0400
Received: from [9.67.60.82] (wecm-9-67-60-82.wecm.ibm.com [9.67.60.82])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9D5iuRc030724
	for <nfs@lists.sourceforge.net>; Fri, 13 Oct 2006 01:44:57 -0400
To: "Linux NFS Mailing List" <nfs@lists.sourceforge.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Trond,
Attached is a tested patch for the bug I posted in the following mail
Marc.

nfs-bounces@lists.sourceforge.net wrote on 10/11/2006 04:28:16 PM:

 > I see an NLM lock reclaim failure (using 2.6.17). Let me describe
 > the simple case first.
 >
 > 1. Client gets an NLM lock
 > 2. Server reboots
 > 3. Client sends lock reclaim request
 > 4. On server, nlm_open() gets return code nfserr_dropit; error gets
 >    converted to nlm_lck_denied by nlm_lookup_file().
 > 5. Client gets status=1, the lock reclaim failed
 >
 > This happens _only_ when the first call to nfsd (fh_verify -> exp_find)
 > comes from lockd trying to find the file. Subsequent calls seem to work.
 >
 > nlm_lookup_file() -> nlm_fopen() -> nfsd_open() -> fh_verify() ->
 > exp_find() returns nfserr_dropit
 >
 > This problem may be related to the following commit to lockd (Trond's
 > tree):
 > commit: 26bcbf965f857c710adafd16cf424f043006b5dd
 > lockd: stop abusing file_lock_list
 >
 > The client earlier retained the list of outstanding locks regardless of
 > reclaim return code. The change above removes all locks from the list
 > and only adds them back after a successful reclaim. Since the reclaim
 > fails, it is removed from the list; so the client will not try to
 > reclaim the lock on a second failure.
 >
 > Note that the problem is not on the client side - it seems the server
 > that should drop the rpc when it gets nfserr_dropit error and not
 > convert it to an nlm_lck_denied.
 >
 > It get even more complicated - when the server doesn't respond
 > immediately to the reclaim, client will retry the rpc, on the second
 > reclaim call, the server will grant the lock to the client but since the
 > client already got the nlm_lck_denied from the first call, it has
 > dropped it from it list. So now we have a lock on the server for a
 > client that doesn't know that it holds the lock.
 >
 > Marc.
 >

Index: lockd/svc.c
===================================================================
RCS file: /cvs/nfsv4/cvs/pnfs/fs/lockd/svc.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 svc.c
--- lockd/svc.c	12 Jul 2006 19:53:39 -0000	1.1.1.4
+++ lockd/svc.c	13 Oct 2006 04:03:13 -0000
@@ -34,6 +34,7 @@
 #include <linux/sunrpc/svcsock.h>
 #include <linux/lockd/lockd.h>
 #include <linux/nfs.h>
+#include <linux/nfsd/nfsd.h>
 
 #define NLMDBG_FACILITY		NLMDBG_SVC
 #define LOCKD_BUFSIZE		(1024 + NLMSVC_XDRSIZE)
@@ -320,6 +321,43 @@
 }
 EXPORT_SYMBOL(lockd_down);
 
+int
+nlmsvc_dispatch(struct svc_rqst *rqstp, u32 *statp)
+{
+	struct svc_procedure	*procp;
+	kxdrproc_t		xdr;
+	struct kvec *		argv = &rqstp->rq_arg.head[0];
+	struct kvec *		resv = &rqstp->rq_res.head[0];
+
+	dprintk("lockd: nlmsvc_dispatch vers %d proc %d\n",
+				rqstp->rq_vers, rqstp->rq_proc);
+
+	procp = rqstp->rq_procinfo;
+
+	/* Decode arguments */
+	xdr = procp->pc_decode;
+
+	if (xdr && !xdr(rqstp, argv->iov_base, rqstp->rq_argp)) {
+		dprintk("lockd: failed to decode arguments!\n");
+		*statp = rpc_garbage_args;
+		return 1;
+	}
+	/* Now call the procedure handler, and encode status. */
+	*statp = procp->pc_func(rqstp, rqstp->rq_argp, rqstp->rq_resp);
+	if (((struct nlm_res  *)(rqstp->rq_resp))->status == nfserr_dropit) {
+		dprintk("lockd: dropping request!\n");
+		return 0;
+	}
+	/* Encode reply */
+	if (*statp == rpc_success && (xdr = procp->pc_encode)
+	    && !xdr(rqstp, resv->iov_base+resv->iov_len, rqstp->rq_resp)) {
+			dprintk("lockd: failed to encode reply\n");
+			/* serv->sv_stats->rpcsystemerr++; */
+			*statp = rpc_system_err;
+	}
+	return 1;
+}
+
 /*
  * Sysctl parameters (same as module parameters, different interface).
  */
@@ -484,12 +522,14 @@
 		.vs_vers	= 1,
 		.vs_nproc	= 17,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch	= nlmsvc_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 static struct svc_version	nlmsvc_version3 = {
 		.vs_vers	= 3,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures,
+		.vs_dispatch	= nlmsvc_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #ifdef CONFIG_LOCKD_V4
@@ -497,6 +537,7 @@
 		.vs_vers	= 4,
 		.vs_nproc	= 24,
 		.vs_proc	= nlmsvc_procedures4,
+		.vs_dispatch	= nlmsvc_dispatch,
 		.vs_xdrsize	= NLMSVC_XDRSIZE,
 };
 #endif
Index: lockd/svcsubs.c
===================================================================
RCS file: /cvs/nfsv4/cvs/pnfs/fs/lockd/svcsubs.c,v
retrieving revision 1.1.1.4
diff -u -r1.1.1.4 svcsubs.c
--- lockd/svcsubs.c	12 Jul 2006 19:53:39 -0000	1.1.1.4
+++ lockd/svcsubs.c	13 Oct 2006 04:03:13 -0000
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfsd/nfsfh.h>
 #include <linux/nfsd/export.h>
+#include <linux/nfsd/nfsd.h>
 #include <linux/lockd/lockd.h>
 #include <linux/lockd/share.h>
 #include <linux/lockd/sm_inter.h>
@@ -136,12 +137,14 @@
 
 out_free:
 	kfree(file);
+	if (nfserr != nfserr_dropit) {
 #ifdef CONFIG_LOCKD_V4
-	if (nfserr == 1)
-		nfserr = nlm4_stale_fh;
-	else
+		if (nfserr == 1)
+			nfserr = nlm4_stale_fh;
+		else
 #endif
-	nfserr = nlm_lck_denied;
+		nfserr = nlm_lck_denied;
+	}
 	goto out_unlock;
 }
 
Index: nfsd/lockd.c
===================================================================
RCS file: /cvs/nfsv4/cvs/pnfs/fs/nfsd/lockd.c,v
retrieving revision 1.1.1.3
diff -u -r1.1.1.3 lockd.c
--- nfsd/lockd.c	4 Apr 2006 17:55:25 -0000	1.1.1.3
+++ nfsd/lockd.c	13 Oct 2006 04:03:14 -0000
@@ -49,6 +49,8 @@
 		return 0;
 	case nfserr_stale:
 		return 1;
+	case nfserr_dropit:
+		return nfserr;
 	default:
 		return 2;
 	}



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
