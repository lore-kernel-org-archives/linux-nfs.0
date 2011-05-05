Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:49013 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab1EEP6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2011 11:58:13 -0400
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p45FfxPW008999
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 09:41:59 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p45Fw2fs080648
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 09:58:02 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p45G33Sb008720
	for <linux-nfs@vger.kernel.org>; Thu, 5 May 2011 10:03:03 -0600
Date: Thu, 5 May 2011 10:57:30 -0500
From: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, ecryptfs-devel@lists.launchpad.net
Subject: Re: [PATCH] NFS: Allow NULL nameidata in d_revalidate and create
Message-ID: <20110505155728.GB12250@boyd.l.tihix.com>
References: <1304609741-12541-1-git-send-email-tyhicks@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1304609741-12541-1-git-send-email-tyhicks@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu May 05, 2011 at 10:35:41AM -0500, Tyler Hicks <tyhicks@linux.vnet.ibm.com> wrote:
> To add support for eCryptfs mounts on top of NFS client mounts, the NFS
> client must properly handle NULL nameidata pointers in its d_revalidate
> functions.
> 
> NFS clients should also handle NULL nameidata in its create functions,
> although this is not currently required for eCryptfs support.
> 
> Signed-off-by: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
> ---

We (eCryptfs) are in the process of switching mailing lists, so I copied
both the old (launchpad.net) and the new (vger.kernel.org), but it
doesn't look like the vger.kernel.org list is accepting mail yet. Sorry
about that, I should have tested it first. Feel free to drop it from
any replies.

I should also mention that if/when this patch is merged, eCryptfs will
have basic support of mounting on top of NFSv3 client mounts. I say
basic because I'm sure there are some bugs, I'm not yet confident that
the required cache flushes are there in the eCryptfs layer to have NFSv3
cache consistency, and we have some trouble with silly rename.

All files unlinked through eCryptfs get silly renamed in the NFS client
because of the extra reference eCryptfs holds on the NFS dentry.

This also seems to come into play when unlinking the last file in a
directory and then immediately removing the directory. nfs_rmdir() will
sometimes return -EBUSY.

BTW, I think these are all issues that should be handled in the eCryptfs
layer, but I wanted to provide an update on the status of eCryptfs on
top of NFS.

Tyler

>  fs/nfs/dir.c |    8 ++++----
>  1 files changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 7237672..03c6ab2 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1095,7 +1095,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct nfs_fattr *fattr = NULL;
>  	int error;
> 
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> 
>  	parent = dget_parent(dentry);
> @@ -1493,7 +1493,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
>  	struct nfs_open_context *ctx;
>  	int openflags, ret = 0;
> 
> -	if (nd->flags & LOOKUP_RCU)
> +	if (nd && nd->flags & LOOKUP_RCU)
>  		return -ECHILD;
> 
>  	inode = dentry->d_inode;
> @@ -1583,7 +1583,7 @@ static int nfs_open_create(struct inode *dir, struct dentry *dentry, int mode,
>  	attr.ia_mode = mode;
>  	attr.ia_valid = ATTR_MODE;
> 
> -	if ((nd->flags & LOOKUP_CREATE) != 0) {
> +	if (nd && (nd->flags & LOOKUP_CREATE) != 0) {
>  		open_flags = nd->intent.open.flags;
> 
>  		ctx = nameidata_to_nfs_open_context(dentry, nd);
> @@ -1673,7 +1673,7 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
>  	attr.ia_mode = mode;
>  	attr.ia_valid = ATTR_MODE;
> 
> -	if ((nd->flags & LOOKUP_CREATE) != 0)
> +	if (nd && (nd->flags & LOOKUP_CREATE) != 0)
>  		open_flags = nd->intent.open.flags;
> 
>  	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, NULL);
> -- 
> 1.7.4.4
> 
