Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54205 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756293Ab2DLUtw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Apr 2012 16:49:52 -0400
Date: Thu, 12 Apr 2012 16:49:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Bernd Schubert <bernd.schubert@fastmail.fm>,
        "Ted Ts'o" <tytso@mit.edu>, linux-nfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        yong.fan@whamcloud.com, sandeen@redhat.com, adilger@whamcloud.com
Subject: Re: [PATCH 5 3/4] nfsd_open(): rename 'int access' to 'int
 may_flags' in nfsd_open()
Message-ID: <20120412204948.GE6667@fieldses.org>
References: <20120309205148.GB5635@thunk.org>
 <20120312150912.GB12440@thunk.org>
 <20120312154921.GB17153@pad.fieldses.org>
 <20120312222250.GD8991@fieldses.org>
 <20120313200117.GA21991@fieldses.org>
 <4F5FA827.8020606@itwm.fraunhofer.de>
 <20120313203446.GB21991@fieldses.org>
 <4F5FB771.9010805@fastmail.fm>
 <20120313212947.GK31995@pad.fieldses.org>
 <4F60AC0D.9020204@itwm.fraunhofer.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4F60AC0D.9020204@itwm.fraunhofer.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 14, 2012 at 03:32:45PM +0100, Bernd Schubert wrote:
> On 03/13/2012 10:29 PM, J. Bruce Fields wrote:
> > On Tue, Mar 13, 2012 at 10:09:05PM +0100, Bernd Schubert wrote:
> >> Hmm, there must have gone something wrong on merging,
> >
> > In that case one approach would be to rebase your last-sent patches on
> > to the same base as Ted's versions, confirm that one still works and the
> > other doesn't, and do a diff....
> >
> >> my own test
> >> also fails
> >>
> >> http://www.pci.uni-heidelberg.de/tc/usr/bernd/downloads/test_seekdir/
> >>
> >> (Sorry, it does not say 'failure', but one needs to compare the file
> >> names and telldir-offset numbers)
> >>
> >> I think I will continue in the morning as its already 1 a.m. here.
> >
> > OK, thanks for following up!

Stupid question: is there any fundamental feature of ext4 this depends
on, or would this fix work equally well for fs/ext3?

--b.

> 
> Took me some time to figure out what is going on and in the end I previously forgot 
> another test case - I always tested directories being sufficiently large, so that 
> they got the EXT4_INODE_INDEX flag. However, the cython tests failed on a small 
> directory, which doesn't have that flag. But then ext4_readdir() always uses the 
> dx version, I guess in order to always return the same offset values 
> (in the sense of converting a non-dx dir to dx). In ext4_dir_llseek() I only 
> tested for the EXT4_INODE_INDEX flag, which is not correct in any case.
> So here is the patch, shall I sent an updated version of the previous ext4 patch 
> or is this patch sufficient?
> 
> Signed-off-by: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>
> 
> diff --git a/fs/ext4/dir.c b/fs/ext4/dir.c
> index 71a66ff..6a19a35 100644
> --- a/fs/ext4/dir.c
> +++ b/fs/ext4/dir.c
> @@ -44,6 +44,24 @@ static unsigned char get_dtype(struct super_block *sb, int filetype)
>  	return (ext4_filetype_table[filetype]);
>  }
>  
> +/**
> + * Check if the given dir-inode refers to an htree indexed directory
> + *
> + * Return 1 if it is a dx dir, 0 if not
> + */
> +static int is_dx_dir(struct inode *inode)
> +{
> +	struct super_block *sb = inode->i_sb;
> +
> +	if (EXT4_HAS_COMPAT_FEATURE(inode->i_sb,
> +		     EXT4_FEATURE_COMPAT_DIR_INDEX) &&
> +	    ((ext4_test_inode_flag(inode, EXT4_INODE_INDEX)) ||
> +	     ((inode->i_size >> sb->s_blocksize_bits) == 1)))
> +		return 1;
> +
> +	return 0;
> +}
> +
>  /*
>   * Return 0 if the directory entry is OK, and 1 if there is a problem
>   *
> @@ -99,18 +117,13 @@ static int ext4_readdir(struct file *filp,
>  	unsigned int offset;
>  	int i, stored;
>  	struct ext4_dir_entry_2 *de;
> -	struct super_block *sb;
>  	int err;
>  	struct inode *inode = filp->f_path.dentry->d_inode;
> +	struct super_block *sb = inode->i_sb;
>  	int ret = 0;
>  	int dir_has_error = 0;
>  
> -	sb = inode->i_sb;
> -
> -	if (EXT4_HAS_COMPAT_FEATURE(inode->i_sb,
> -				    EXT4_FEATURE_COMPAT_DIR_INDEX) &&
> -	    ((ext4_test_inode_flag(inode, EXT4_INODE_INDEX)) ||
> -	     ((inode->i_size >> sb->s_blocksize_bits) == 1))) {
> +	if (is_dx_dir(inode)) {
>  		err = ext4_dx_readdir(filp, dirent, filldir);
>  		if (err != ERR_BAD_DX_DIR) {
>  			ret = err;
> @@ -308,7 +321,7 @@ loff_t ext4_dir_llseek(struct file *file, loff_t offset, int origin)
>  {
>  	struct inode *inode = file->f_mapping->host;
>  	loff_t ret = -EINVAL;
> -	int is_dx_dir = ext4_test_inode_flag(inode, EXT4_INODE_INDEX);
> +	int dx_dir = is_dx_dir(inode);
>  
>  	mutex_lock(&inode->i_mutex);
>  
> @@ -323,7 +336,7 @@ loff_t ext4_dir_llseek(struct file *file, loff_t offset, int origin)
>  
>  		/* so only negative offsets are left, does that have a
>  		 * meaning for directories at all? */
> -		if (is_dx_dir)
> +		if (dx_dir)
>  			offset += ext4_get_htree_eof(file);
>  		else
>  			offset += inode->i_size;
> @@ -347,7 +360,7 @@ loff_t ext4_dir_llseek(struct file *file, loff_t offset, int origin)
>  	if (unlikely(offset < 0))
>  		goto out_err;
>  
> -	if (!is_dx_dir) {
> +	if (!dx_dir) {
>  		if (offset > inode->i_sb->s_maxbytes)
>  			goto out_err;
>  	} else if (offset > ext4_get_htree_eof(file))
> 
> 
> 
> 
