Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:54540 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027Ab3LDWtN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 17:49:13 -0500
Received: by mail-ie0-f178.google.com with SMTP id lx4so27862755iec.37
        for <linux-nfs@vger.kernel.org>; Wed, 04 Dec 2013 14:49:13 -0800 (PST)
Message-ID: <1386197350.31895.2.camel@leira.trondhjem.org>
Subject: Re: Patch for mapping EILSEQ into NFSERR_INVAL
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Dr Fields James Bruce <bfields@fieldses.org>
Cc: Antti =?ISO-8859-1?Q?T=F6nkyr=E4?= <daedalus@pingtimeout.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Wed, 04 Dec 2013 17:49:10 -0500
In-Reply-To: <20131204213804.GC19452@fieldses.org>
References: <529CEBC3.8060505@pingtimeout.net>
	 <FA468B61-5F7E-4A88-A0BD-13BCF115282E@primarydata.com>
	 <529CF322.4080701@pingtimeout.net> <20131203204806.GA2648@fieldses.org>
	 <20131203212210.GC2648@fieldses.org> <529ED1C8.70208@pingtimeout.net>
	 <20131204154104.GB14646@fieldses.org> <529F943D.30004@pingtimeout.net>
	 <20131204210356.GA19452@fieldses.org>
	 <22997028-AB15-4D61-A263-011867EE7512@primarydata.com>
	 <20131204213804.GC19452@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-12-04 at 16:38 -0500, Dr Fields James Bruce wrote:
> On Wed, Dec 04, 2013 at 04:22:48PM -0500, Trond Myklebust wrote:
> > 
> > On Dec 4, 2013, at 16:03, Dr Fields James Bruce <bfields@fieldses.org> wrote:
> > 
> > > On Wed, Dec 04, 2013 at 10:44:45PM +0200, Antti Tönkyrä wrote:
> > > 
> > >>>> http://daedalus.pingtimeout.net/dbg/eilseq_ioerr.pcap
> > > 
> > > And I see something I'd overlooked before: the client is sending the
> > > later opens with the same open owner and sequence id.  But NFS4ERR_IO is
> > > a seqid-mutating error.  So now I think this probably *is* a client
> > > bug....
> > 
> > Umm… Yes and no. The client should be able to recover when it discovers that the seqid is out of sync.
> >
> > That said, I see that we do
> > 
> >        status = decode_op_hdr(xdr, OP_OPEN);
> >         if (status != -EIO)
> >                 nfs_increment_open_seqid(status, res->seqid);
> > 
> > and since NFS4ERR_IO == EIO, that means we skip the seqid update when you send us NFS4ERR_IO.
> 
> Oh, OK.  Maybe decode_op_hdr could use -NFS4ERR_BADXDR for the two
> decoding errors it catches and eliminate the need for this special -EIO
> case?

That is sort of hackish. How about something like the following patch.

> I think NFS4ERR_IO is a legal error for these operations.  (Even if the
> server should have returned something else in this case.)

It is legal for OPEN. It does not seem to be legal for OPEN_CONFIRM,
LOCK, LOCKU, CLOSE or OPEN_DOWNGRADE according to RFC3530bis.

Cheers
  Trond

8<--------------------------------------------------------
>From 968a89bfaf176d70352bb1c0003bf496fdc180aa Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Wed, 4 Dec 2013 17:39:23 -0500
Subject: [PATCH] NFSv4: OPEN must handle the NFS4ERR_IO return code correctly

decode_op_hdr() cannot distinguish between an XDR decoding error and
the perfectly valid errorcode NFS4ERR_IO. This is normally not a
problem, but for the particular case of OPEN, we need to be able
to increment the NFSv4 open sequence id when the server returns
a valid response.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 47 +++++++++++++++++++++++++++++++----------------
 1 file changed, 31 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 5be2868c02f1..8c21d69a9dc1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3097,7 +3097,8 @@ out_overflow:
 	return -EIO;
 }
 
-static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
+static bool __decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected,
+		int *nfs_retval)
 {
 	__be32 *p;
 	uint32_t opnum;
@@ -3107,19 +3108,32 @@ static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
 	if (unlikely(!p))
 		goto out_overflow;
 	opnum = be32_to_cpup(p++);
-	if (opnum != expected) {
-		dprintk("nfs: Server returned operation"
-			" %d but we issued a request for %d\n",
-				opnum, expected);
-		return -EIO;
-	}
+	if (unlikely(opnum != expected))
+		goto out_bad_operation;
 	nfserr = be32_to_cpup(p);
-	if (nfserr != NFS_OK)
-		return nfs4_stat_to_errno(nfserr);
-	return 0;
+	if (nfserr == NFS_OK)
+		*nfs_retval = 0;
+	else
+		*nfs_retval = nfs4_stat_to_errno(nfserr);
+	return true;
+out_bad_operation:
+	dprintk("nfs: Server returned operation"
+		" %d but we issued a request for %d\n",
+			opnum, expected);
+	*nfs_retval = -EREMOTEIO;
+	return false;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return -EIO;
+	*nfs_retval = -EIO;
+	return false;
+}
+
+static int decode_op_hdr(struct xdr_stream *xdr, enum nfs_opnum4 expected)
+{
+	int retval;
+
+	__decode_op_hdr(xdr, expected, &retval);
+	return retval;
 }
 
 /* Dummy routine */
@@ -5001,11 +5015,12 @@ static int decode_open(struct xdr_stream *xdr, struct nfs_openres *res)
 	uint32_t savewords, bmlen, i;
 	int status;
 
-	status = decode_op_hdr(xdr, OP_OPEN);
-	if (status != -EIO)
-		nfs_increment_open_seqid(status, res->seqid);
-	if (!status)
-		status = decode_stateid(xdr, &res->stateid);
+	if (!__decode_op_hdr(xdr, OP_OPEN, &status))
+		return status;
+	nfs_increment_open_seqid(status, res->seqid);
+	if (status)
+		return status;
+	status = decode_stateid(xdr, &res->stateid);
 	if (unlikely(status))
 		return status;
 
-- 
1.8.3.1



