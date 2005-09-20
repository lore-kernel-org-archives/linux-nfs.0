From: Steven <steven@void.org>
Subject: Minor problem in nfsv3 write
Date: Mon, 19 Sep 2005 18:10:46 -0700
Message-ID: <20050920011046.23A07F4@dead.void.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHWfR-00043Y-Fs
	for nfs@lists.sourceforge.net; Mon, 19 Sep 2005 18:11:29 -0700
Received: from dsl092-218-023.sfo2.dsl.speakeasy.net ([66.92.218.23] helo=chaotic.void.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHWfP-0000Cy-4t
	for nfs@lists.sourceforge.net; Mon, 19 Sep 2005 18:11:29 -0700
Received: from dead.void.org ([192.168.54.11])
	by chaotic.void.org (8.13.1/8.10.2/SuSE Linux 8.10.0-0.3) with ESMTP id j8K1lRki008576
	for <nfs@lists.sourceforge.net>; Mon, 19 Sep 2005 18:47:27 -0700
Received: from dead.void.org (localhost [127.0.0.1])
	by dead.void.org (Postfix) with ESMTP id 23A07F4
	for <nfs@lists.sourceforge.net>; Mon, 19 Sep 2005 18:10:46 -0700 (PDT)
To: nfs@lists.sourceforge.net
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


There is a minor bug in the way writes are handled in nfs3.  If the
client requests a write for more than 32k of data the server will only
write 32k but report that it wrote the whole amount.

This happens when nfs3svc_decode_writeargs caps the amount that can be
written to NFSSVC_MAXBLKSIZE (which is 32k), by limiting the amount that
it copies into the args object (fs/nfsd/nfs3xdr.c:375).  The amount that
is reported to the client is copied from the request packet, which is
the amount the client requested (fs/nfsd/nfs3proc.c:209) not the amount
which was written.

I think the right thing to do is adjust the amount in the request object
to the amount that will be written in the decoder. 

Following is an modified version of nfs3svc_decode_writeargs and diffs
against a 2.6.13 kernel which does this.

--Steven

int
nfs3svc_decode_writeargs(struct svc_rqst *rqstp, u32 *p,
                                        struct nfsd3_writeargs *args)
{
        unsigned int len, v, hdr;

        if (!(p = decode_fh(p, &args->fh))
         || !(p = xdr_decode_hyper(p, &args->offset)))
                return 0;

        args->count = ntohl(*p++);
        args->stable = ntohl(*p++);
        len = args->len = ntohl(*p++);

        hdr = (void*)p - rqstp->rq_arg.head[0].iov_base;
        if (rqstp->rq_arg.len < len + hdr)
                return 0;

        args->vec[0].iov_base = (void*)p;
        args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;

        if (len > NFSSVC_MAXBLKSIZE) {
                len = NFSSVC_MAXBLKSIZE;
                /* adjust count to match the amount that will be written */
                args->count = len;
        }
        v=  0;
        while (len > args->vec[v].iov_len) {
                len -= args->vec[v].iov_len;
                v++;
                args->vec[v].iov_base = page_address(rqstp->rq_argpages[v]);
                args->vec[v].iov_len = PAGE_SIZE;
        }
        args->vec[v].iov_len = len;
        args->vlen = v+1;

        /* args->count may be less than args->len since it is capped */
        return args->count <= args->len && args->vec[0].iov_len > 0;
}

*** fs/nfsd/nfs3xdr.c.orig	Fri Sep 16 18:02:12 2005
--- fs/nfsd/nfs3xdr.c	Mon Sep 19 17:35:22 2005
***************
*** 372,379 ****
  	args->vec[0].iov_base = (void*)p;
  	args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
  
! 	if (len > NFSSVC_MAXBLKSIZE)
  		len = NFSSVC_MAXBLKSIZE;
  	v=  0;
  	while (len > args->vec[v].iov_len) {
  		len -= args->vec[v].iov_len;
--- 372,382 ----
  	args->vec[0].iov_base = (void*)p;
  	args->vec[0].iov_len = rqstp->rq_arg.head[0].iov_len - hdr;
  
! 	if (len > NFSSVC_MAXBLKSIZE) {
  		len = NFSSVC_MAXBLKSIZE;
+ 		/* adjust count to match the amount that will be written */
+ 		args->count = len;
+ 	}
  	v=  0;
  	while (len > args->vec[v].iov_len) {
  		len -= args->vec[v].iov_len;
***************
*** 384,390 ****
  	args->vec[v].iov_len = len;
  	args->vlen = v+1;
  
! 	return args->count == args->len && args->vec[0].iov_len > 0;
  }
  
  int
--- 387,394 ----
  	args->vec[v].iov_len = len;
  	args->vlen = v+1;
  
! 	/* args->count may be less than args->len since it is capped */
! 	return args->count <= args->len && args->vec[0].iov_len > 0;
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
