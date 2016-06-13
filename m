Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55236 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424518AbcFMQBj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2016 12:01:39 -0400
Date: Mon, 13 Jun 2016 12:01:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Eshel <eshel@us.ibm.com>
Cc: linux-nfs@vger.kernel.org, Srikanth Srinivasan <ssrikanth@in.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Venkateswara R Puvvada <vpuvvada@in.ibm.com>
Subject: Re: NFS fixes
Message-ID: <20160613160138.GD17866@fieldses.org>
References: <OF9C78122D.D4F282BF-ON88257FD0.00686038-88257FD0.006E09F0@LocalDomain>
 <OFAE63B935.50A753D1-ON88257FD0.00812E5D-88257FD0.0081788A@LocalDomain>
 <OF4D8DDA37.ED72F2E9-ON88257FD1.00031E93-88257FD1.0003298D@notes.na.collabserv.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF4D8DDA37.ED72F2E9-ON88257FD1.00031E93-88257FD1.0003298D@notes.na.collabserv.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 12, 2016 at 05:34:32PM -0700, Marc Eshel wrote:
> We are seeing a data corruption when putting very high load on the NFS V3 
> client reading multi gigabyte files in parallel. The check-sum on the 
> files is showing the corruption, and looking at the data we see data that 
> in one block that belongs in another block but it is not the full block. 
> The test is done on multiple set of hardware using different type of 
> server including kNFS and Ganesha servers with EXT3 or GPFS file system. 
> The only common part in all test are NFSv3 client on REHL7.0, 7.1, 7.2.
> 
> The question is there anything up stream that might fix data corruption by 
> the NFSv3 client, oo do we know if this problem might have been reported 
> by other users.
> 
> The only fix that I see that might be related is attached, can this 
> explain a data corruption?

It should be pretty easy to check whether there've been any READ/WRITE
errors, and rule this out if not.

Is the data being read completely static?  (So you can rule out e.g.
some subtle violation of close-to-open.)

Sorry, no special knowledge here.

--b.

> 
> Thanks, Marc. 
> 
> 
> Author: Trond Myklebust <trond.myklebust@primarydata.com>
> Date:   Mon Aug 17 12:57:07 2015 -0500
> 
>     NFS: nfs_set_pgio_error sometimes misses errors
>  
>     We should ensure that we always set the pgio_header's error field
>     if a READ or WRITE RPC call returns an error. The current code depends
>     on 'hdr->good_bytes' always being initialised to a large value, which
>     is not always done correctly by callers.
>     When this happens, applications may end up missing important errors.
>  
>     Cc: stable@vger.kernel.org
>     Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
> index 4984bbe..7c5718b 100644
> --- a/fs/nfs/pagelist.c
> +++ b/fs/nfs/pagelist.c
> @@ -77,8 +77,8 @@ EXPORT_SYMBOL_GPL(nfs_pgheader_init);
>  void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t 
> pos)
>  {
>         spin_lock(&hdr->lock);
> -       if (pos < hdr->io_start + hdr->good_bytes) {
> -               set_bit(NFS_IOHDR_ERROR, &hdr->flags);
> +       if (!test_and_set_bit(NFS_IOHDR_ERROR, &hdr->flags)
> +           || pos < hdr->io_start + hdr->good_bytes) {
>                 clear_bit(NFS_IOHDR_EOF, &hdr->flags);
>                 hdr->good_bytes = pos - hdr->io_start;
> 
> \
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
