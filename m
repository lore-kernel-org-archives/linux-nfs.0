Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40078 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751141AbcDOOZG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Apr 2016 10:25:06 -0400
Date: Fri, 15 Apr 2016 10:25:00 -0400
To: Trond Myklebust <trondmy@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: ls -l regression from 311324ad1713
Message-ID: <20160415142500.GB23176@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This change is making "ls -l" of large changing directories slower:

    commit 311324ad1713
    Author: Trond Myklebust <trond.myklebust@primarydata.com>
    Date:   Fri Feb 7 17:02:08 2014 -0500

    NFS: Be more aggressive in using readdirplus for 'ls -l' situations
    
    Try to detect 'ls -l' by having nfs_getattr() look at whether or not
    there is an opendir() file descriptor for the parent directory.
    If so, then assume that we want to force use of readdirplus in order
    to avoid the multiple GETATTR calls over the wire.
    
    Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

After that commit, if we create a large directory and then add and
remove entries from it continuously while doing an "ls -l", we see
multiple READDIRPLUS requests sent with cookie 0; it appears the readdir
is starting over from the beginning of the directory repeatedly.

It doesn't appear to be the changes to nfs_getattr that do this, instead
it's just the change to nfs_readdir to call nfs_revalidate_mapping() in
the case INVALID_DATA is set (as opposed to only in the case the
directory's attribute cache has expired):

    +static bool nfs_dir_mapping_need_revalidate(struct inode *dir)
    +{
    +	struct nfs_inode *nfsi = NFS_I(dir);
    +
    +	if (nfs_attribute_cache_expired(dir))
    +		return true;
    +	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
    +		return true;
    +	return false;
    +}
    ...
    @@ -847,7 +881,7 @@ static int nfs_readdir(...
     	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
     
     	nfs_block_sillyrename(dentry);
    -	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
    +	if (ctx->pos == 0 || nfs_dir_mapping_need_revalidate(inode))
     		res = nfs_revalidate_mapping(inode, file->f_mapping);
     	if (res < 0)
     		goto out;


I assume (haven't checked) that INVALID_DATA is getting set when
READDIRPLUS's notice a change in the post_op_attr's?

I'm not sure what the correct behavior is here--any suggestions?

--b.
