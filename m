Return-Path: <SRS0=aRlV=NH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.5 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 127EDC46475
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 11:11:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A6FF120869
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 11:11:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="XHYYRG+d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6FF120869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728514AbeJ0TwF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 15:52:05 -0400
Received: from mail.kernel.org ([198.145.29.99]:33056 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728477AbeJ0TwF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 27 Oct 2018 15:52:05 -0400
Received: from tleilax.poochiereds.net (cpe-71-70-156-158.nc.res.rr.com [71.70.156.158])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id BCD9220856;
        Sat, 27 Oct 2018 11:11:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1540638688;
        bh=H4wYra2szJfXftaTXcJUlv6J7Igu3BxRKM71HsG/Ar0=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=XHYYRG+dOQwoSzOj156RO7jQe1LHoTL54XGrxhlY9LDpyw9yhzWSHeVyRJZkRs6P+
         3eb5RFMXtb8ynLspSynF39KbYvLkdomvDz6IRDf16swEDn7cC1PTkFBZS+5V3eT5RM
         smTyh4ulYmK6S17Oh0YN8bJX9zXOlT0hoje6VEXY=
Message-ID: <0833b9e12068007de42c681166a60a9cbaf0cb6b.camel@kernel.org>
Subject: Re: [PATCH v4 01/11] VFS: move cross device copy_file_range() check
 into filesystems
From:   Jeff Layton <jlayton@kernel.org>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>,
        trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Date:   Sat, 27 Oct 2018 07:11:25 -0400
In-Reply-To: <20181026201057.36899-2-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
         <20181026201057.36899-2-olga.kornievskaia@gmail.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.28.5 (3.28.5-1.fc28) 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, 2018-10-26 at 16:10 -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> This patch makes it the responsibility of individual filesystems to
> allow or deny cross device copies.  Both NFS and CIFS have operations
> for cross-server copies, and later patches will implement this feature.
> 
> Note that as of this patch, the copy_file_range() function might be passed
> superblocks from different filesystem types. -EXDEV should be returned
> if cross device copies aren't supported, causing the VFS to fall back
> on using do_splice_direct().
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  Documentation/filesystems/porting | 7 +++++++
>  fs/cifs/cifsfs.c                  | 3 +++
>  fs/nfs/nfs4file.c                 | 3 +++
>  fs/overlayfs/file.c               | 3 +++
>  fs/read_write.c                   | 9 +++------
>  5 files changed, 19 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/filesystems/porting b/Documentation/filesystems/porting
> index 7b7b845..897e1e7 100644
> --- a/Documentation/filesystems/porting
> +++ b/Documentation/filesystems/porting
> @@ -622,3 +622,10 @@ in your dentry operations instead.
>  	alloc_file_clone(file, flags, ops) does not affect any caller's references.
>  	On success you get a new struct file sharing the mount/dentry with the
>  	original, on failure - ERR_PTR().
> +--
> +[mandatory]
> +	->copy_file_range() may now be passed files which belong to two
> +	different superblocks of the same file system type or which belong
> +	to two different filesystems types all together. As before, the
> +	destination's copy_file_range() is the function which is called.
> +	If it cannot copy ranges from the source, it should return -EXDEV.
> diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
> index 7065426..f2d7f4f 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
>  	unsigned int xid = get_xid();
>  	ssize_t rc;
>  
> +	if (src_file->f_inode->i_sb != dst_file->f_inode->i_sb)
> +		return -EXDEV;
> +
>  	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
>  					len, flags);
>  	free_xid(xid);
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 4288a6e..09df688 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  {
>  	ssize_t ret;
>  
> +	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> +		return -EXDEV;
> +
>  	if (file_inode(file_in) == file_inode(file_out))
>  		return -EINVAL;
>  retry:
> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index aeaefd2..5282853 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>  				   struct file *file_out, loff_t pos_out,
>  				   size_t len, unsigned int flags)
>  {
> +	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
> +		return -EXDEV;
> +
>  	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
>  			    OVL_COPY);
>  }
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 39b4a21..fb4ffca 100644
> --- a/fs/read_write.c
> +++ b/fs/read_write.c
> @@ -1575,10 +1575,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	    (file_out->f_flags & O_APPEND))
>  		return -EBADF;
>  
> -	/* this could be relaxed once a method supports cross-fs copies */
> -	if (inode_in->i_sb != inode_out->i_sb)
> -		return -EXDEV;
> -
>  	if (len == 0)
>  		return 0;
>  
> @@ -1588,7 +1584,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	 * Try cloning first, this is supported by more file systems, and
>  	 * more efficient if both clone and copy are supported (e.g. NFS).
>  	 */
> -	if (file_in->f_op->clone_file_range) {
> +	if (inode_in->i_sb == inode_out->i_sb &&
> +			file_in->f_op->clone_file_range) {
>  		ret = file_in->f_op->clone_file_range(file_in, pos_in,
>  				file_out, pos_out, len);
>  		if (ret == 0) {
> @@ -1600,7 +1597,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	if (file_out->f_op->copy_file_range) {
>  		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
>  						      pos_out, len, flags);
> -		if (ret != -EOPNOTSUPP)
> +		if (ret != -EOPNOTSUPP && ret != -EXDEV)
>  			goto done;
>  	}
>  

Yes, this is the right way to do this sort of change, IMO. Push the
checks down into the fs' so they can be relaxed on a case-by-case basis.

Modulo dchinner's comments, this looks fine.

Reviewed-by: Jeff Layton <jlayton@kernel.org>

