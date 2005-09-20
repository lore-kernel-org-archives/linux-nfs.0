From: Steven <steven@void.org>
Subject: [PATCH] Minor problem in nfsv3 write
Date: Tue, 20 Sep 2005 15:19:10 -0700
Message-ID: <20050920221910.323E8F4@dead.void.org>
References: <20050920011046.23A07F4@dead.void.org> <20050920012525.GA26729@fieldses.org> <432FFFC7.7010803@redhat.com> <20050920183054.BCB62F4@dead.void.org>  <20050920192640.GD31948@fieldses.org>
Cc: Steven <steven@void.org>, Peter Staubach <staubach@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHqSy-0002QS-JP
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 15:19:56 -0700
Received: from dsl092-218-023.sfo2.dsl.speakeasy.net ([66.92.218.23] helo=chaotic.void.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHqSw-0004xM-0J
	for nfs@lists.sourceforge.net; Tue, 20 Sep 2005 15:19:56 -0700
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: Message from "J. Bruce Fields" <bfields@fieldses.org>
   of "Tue, 20 Sep 2005 15:26:40 EDT." <20050920192640.GD31948@fieldses.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


The following changes the nfs write procedure so that it reports the
number of bytes written correctly when the requested write size execeeds
the server's maximum write transfer size.  The server was reporting that
it wrote the number of bytes the client requested, but in fact it only
wrote the max transfer size.

For linux-2.6.13.2.

--Steven Procter

--- fs/nfsd/nfs3xdr.c.orig	2005-09-20 13:49:52.000000000 -0700
+++ fs/nfsd/nfs3xdr.c	2005-09-20 13:49:53.000000000 -0700
@@ -372,8 +372,10 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	args->vec[0].iov_base = (void*)p;
 	args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
 
-	if (len > NFSSVC_MAXBLKSIZE)
+	if (len > NFSSVC_MAXBLKSIZE) {
 		len = NFSSVC_MAXBLKSIZE;
+		args->count = len;
+	}
 	v=  0;
 	while (len > args->vec[v].iov_len) {
 		len -= args->vec[v].iov_len;
@@ -384,7 +386,7 @@ nfs3svc_decode_writeargs(struct svc_rqst
 	args->vec[v].iov_len = len;
 	args->vlen = v+1;
 
-	return args->count == args->len && args->vec[0].iov_len > 0;
+	return args->count <= args->len && args->vec[0].iov_len > 0;
 }
 
 int


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
