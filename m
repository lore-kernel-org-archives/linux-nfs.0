Return-Path: <SRS0=aRlV=NH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCE6FC46475
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 09:09:40 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 922E120665
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Oct 2018 09:09:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 922E120665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=fromorbit.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727685AbeJ0Rtp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 13:49:45 -0400
Received: from ipmail07.adl2.internode.on.net ([150.101.137.131]:59558 "EHLO
        ipmail07.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1726193AbeJ0Rtp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 13:49:45 -0400
Received: from ppp59-167-129-252.static.internode.on.net (HELO dastard) ([59.167.129.252])
  by ipmail07.adl2.internode.on.net with ESMTP; 27 Oct 2018 19:39:25 +1030
Received: from dave by dastard with local (Exim 4.80)
        (envelope-from <david@fromorbit.com>)
        id 1gGKax-0001JM-HI; Sat, 27 Oct 2018 20:09:23 +1100
Date:   Sat, 27 Oct 2018 20:09:23 +1100
From:   Dave Chinner <david@fromorbit.com>
To:     Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: Re: [PATCH v4 01/11] VFS: move cross device copy_file_range() check
 into filesystems
Message-ID: <20181027090923.GJ6311@dastard>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
 <20181026201057.36899-2-olga.kornievskaia@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181026201057.36899-2-olga.kornievskaia@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Oct 26, 2018 at 04:10:46PM -0400, Olga Kornievskaia wrote:
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

file_inode(file)->i_sb, please.

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

Please look at the code around your modifications and make sure your
additions are consistent with it.

> @@ -1588,7 +1584,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>  	 * Try cloning first, this is supported by more file systems, and
>  	 * more efficient if both clone and copy are supported (e.g. NFS).
>  	 */
> -	if (file_in->f_op->clone_file_range) {
> +	if (inode_in->i_sb == inode_out->i_sb &&
> +			file_in->f_op->clone_file_range) {

	if (inode_in->i_sb == inode_out->i_sb &&
	    file_in->f_op->clone_file_range) {

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
