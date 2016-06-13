Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:61530 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933428AbcFMRB5 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 13:01:57 -0400
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5DGwShC082857
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 13:01:57 -0400
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23geh3eg1m-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 13:01:57 -0400
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 13 Jun 2016 11:01:54 -0600
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 1C16B3E40041
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 11:01:53 -0600 (MDT)
Received: from b01ledav004.gho.pok.ibm.com (b01ledav004.gho.pok.ibm.com [9.57.199.109])
	by b01cxnp23033.gho.pok.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u5DH15or37289994
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 17:01:53 GMT
Received: from b01ledav004.gho.pok.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 896BF11206D
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 13:01:52 -0400 (EDT)
Received: from d50lp33.co.us.ibm.com (unknown [9.17.249.38])
	by b01ledav004.gho.pok.ibm.com (Postfix) with ESMTPS id 3EB6D112061
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jun 2016 13:01:52 -0400 (EDT)
Received: from localhost
	by d50lp33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 13 Jun 2016 11:01:51 -0600
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Mon, 13 Jun 2016 17:01:48 -0000
In-Reply-To: <20160613160138.GD17866@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Srikanth Srinivasan <ssrikanth@in.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Venkateswara R Puvvada <vpuvvada@in.ibm.com>
Subject: Re: NFS fixes
From: "Marc Eshel" <eshel@us.ibm.com>
Date: Mon, 13 Jun 2016 10:01:46 -0700
References: <OF9C78122D.D4F282BF-ON88257FD0.00686038-88257FD0.006E09F0@LocalDomain>
 <OFAE63B935.50A753D1-ON88257FD0.00812E5D-88257FD0.0081788A@LocalDomain>
 <OF4D8DDA37.ED72F2E9-ON88257FD1.00031E93-88257FD1.0003298D@notes.na.collabserv.com>
 <20160613160138.GD17866@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Message-Id: <OFD91CE247.B0636D6B-ON88257FD1.005D4E83-88257FD1.005D8B74@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are no error from vfs_read just the data corruption, we tried it 
with DIO and still see the problem, so it might not be the NFS client, we 
are looking again at the memory management of the application.
Thanks, Marc.

linux-nfs-owner@vger.kernel.org wrote on 06/13/2016 09:01:38 AM:

> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: Marc Eshel/Almaden/IBM@IBMUS
> Cc: linux-nfs@vger.kernel.org, Srikanth Srinivasan 
> <ssrikanth@in.ibm.com>, Trond Myklebust 
> <trond.myklebust@primarydata.com>, Venkateswara R Puvvada 
> <vpuvvada@in.ibm.com>
> Date: 06/13/2016 09:01 AM
> Subject: Re: NFS fixes
> Sent by: linux-nfs-owner@vger.kernel.org
> 
> On Sun, Jun 12, 2016 at 05:34:32PM -0700, Marc Eshel wrote:
> > We are seeing a data corruption when putting very high load on the NFS 
V3 
> > client reading multi gigabyte files in parallel. The check-sum on the 
> > files is showing the corruption, and looking at the data we see data 
that 
> > in one block that belongs in another block but it is not the full 
block. 
> > The test is done on multiple set of hardware using different type of 
> > server including kNFS and Ganesha servers with EXT3 or GPFS file 
system. 
> > The only common part in all test are NFSv3 client on REHL7.0, 7.1, 
7.2.
> > 
> > The question is there anything up stream that might fix data 
corruption by 
> > the NFSv3 client, oo do we know if this problem might have been 
reported 
> > by other users.
> > 
> > The only fix that I see that might be related is attached, can this 
> > explain a data corruption?
> 
> It should be pretty easy to check whether there've been any READ/WRITE
> errors, and rule this out if not.
> 
> Is the data being read completely static?  (So you can rule out e.g.
> some subtle violation of close-to-open.)
> 
> Sorry, no special knowledge here.
> 
> --b.
> 
> > 
> > Thanks, Marc. 
> > 
> > 
> > Author: Trond Myklebust <trond.myklebust@primarydata.com>
> > Date:   Mon Aug 17 12:57:07 2015 -0500
> > 
> >     NFS: nfs_set_pgio_error sometimes misses errors
> > 
> >     We should ensure that we always set the pgio_header's error field
> >     if a READ or WRITE RPC call returns an error. The current code 
depends
> >     on 'hdr->good_bytes' always being initialised to a large value, 
which
> >     is not always done correctly by callers.
> >     When this happens, applications may end up missing important 
errors.
> > 
> >     Cc: stable@vger.kernel.org
> >     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> > index 4984bbe..7c5718b 100644
> > --- a/fs/nfs/pagelist.c
> > +++ b/fs/nfs/pagelist.c
> > @@ -77,8 +77,8 @@ EXPORT_SYMBOL_GPL(nfs_pgheader_init);
> >  void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, 
loff_t 
> > pos)
> >  {
> >         spin_lock(&hdr->lock);
> > -       if (pos < hdr->io_start + hdr->good_bytes) {
> > -               set_bit(NFS_IOHDR_ERROR, &hdr->flags);
> > +       if (!test_and_set_bit(NFS_IOHDR_ERROR, &hdr->flags)
> > +           || pos < hdr->io_start + hdr->good_bytes) {
> >                 clear_bit(NFS_IOHDR_EOF, &hdr->flags);
> >                 hdr->good_bytes = pos - hdr->io_start;
> > 
> > \
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


