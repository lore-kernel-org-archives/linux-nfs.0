Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEC83C0044C
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:54:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 61ECA20664
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 18:54:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61ECA20664
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730241AbeKADxt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 23:53:49 -0400
Received: from mx2.suse.de ([195.135.220.15]:48216 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730097AbeKADxt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Oct 2018 23:53:49 -0400
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
        by mx1.suse.de (Postfix) with ESMTP id 5F338B166;
        Wed, 31 Oct 2018 18:54:28 +0000 (UTC)
Date:   Wed, 31 Oct 2018 13:54:25 -0500
From:   Goldwyn Rodrigues <rgoldwyn@suse.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v7 01/11] VFS: move cross device copy_file_range() check
 into filesystems
Message-ID: <20181031185425.lkw7fuoxbls6yam3@merlin>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
 <20181030205614.40754-2-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181030205614.40754-2-olga.kornievskaia@gmail.com>
User-Agent: NeoMutt/20180323
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 16:56 30/10, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <kolga@netapp.com>
> 
> This patch makes it the responsibility of individual filesystems to
> allow or deny cross device copies.  Both NFS and CIFS have operations
> for cross-server copies, and later patches will implement this feature.
> 
> Note that as of this patch, the copy_file_range() function might be passed
> superblocks from different filesystem types. -EXDEV should be returned
> if cross device copies aren't supported.
> 
> Reviewed-by: Amir Goldstein <amir73il@gmail.com>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Reviewed-by: Steve French <stfrench@microsoft.com>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
> ---
>  Documentation/filesystems/porting |  7 +++++++
>  fs/cifs/cifsfs.c                  |  3 +++
>  fs/nfs/nfs4file.c                 |  3 +++
>  fs/overlayfs/file.c               |  3 +++
>  fs/read_write.c                   | 12 +++++++-----
>  5 files changed, 23 insertions(+), 5 deletions(-)
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
> index 7065426..ca8fc87 100644
> --- a/fs/cifs/cifsfs.c
> +++ b/fs/cifs/cifsfs.c
> @@ -1114,6 +1114,9 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
>  	unsigned int xid = get_xid();
>  	ssize_t rc;
>  
> +	if (file_inode(src_file)->i_sb != file_inode(dst_file)->i_sb)
> +		return -EXDEV;
> +
>  	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
>  					len, flags);
>  	free_xid(xid);
> diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> index 4288a6e..5a73c90 100644
> --- a/fs/nfs/nfs4file.c
> +++ b/fs/nfs/nfs4file.c
> @@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
>  {
>  	ssize_t ret;
>  
> +	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> +		return -EXDEV;
> +
>  	if (file_inode(file_in) == file_inode(file_out))
>  		return -EINVAL;
>  retry:
> diff --git a/fs/overlayfs/file.c b/fs/overlayfs/file.c
> index aeaefd2..0331e33 100644
> --- a/fs/overlayfs/file.c
> +++ b/fs/overlayfs/file.c
> @@ -483,6 +483,9 @@ static ssize_t ovl_copy_file_range(struct file *file_in, loff_t pos_in,
>  				   struct file *file_out, loff_t pos_out,
>  				   size_t len, unsigned int flags)
>  {
> +	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
> +		return -EXDEV;
> +
>  	return ovl_copyfile(file_in, pos_in, file_out, pos_out, len, flags,
>  			    OVL_COPY);
>  }
> diff --git a/fs/read_write.c b/fs/read_write.c
> index 39b4a21..c5bed2e 100644
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
> +	    file_in->f_op->clone_file_range) {
>  		ret = file_in->f_op->clone_file_range(file_in, pos_in,
>  				file_out, pos_out, len);
>  		if (ret == 0) {
> @@ -1604,6 +1601,11 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  			goto done;
>  	}
>  
> +	if (inode_in->i_sb != inode_out->i_sb) {
> +		ret = -EXDEV;
> +		goto done;
> +	}
> +

Can we just do away with this check and let it perform splice()? The splice()
call does not need to have file_in and file_out as the same sb.

>  	ret = do_splice_direct(file_in, &pos_in, file_out, &pos_out,
>  			len > MAX_RW_COUNT ? MAX_RW_COUNT : len, 0);
>  
> -- 
> 1.8.3.1
> 

-- 
Goldwyn
