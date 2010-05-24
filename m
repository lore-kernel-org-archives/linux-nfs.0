Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:42138 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755361Ab0EXL7K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 May 2010 07:59:10 -0400
Date: Mon, 24 May 2010 12:59:03 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Neil Brown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] VFS: fix recent breakage of FS_REVAL_DOT
Message-ID: <20100524115903.GP31073@ZenIV.linux.org.uk>
References: <20100524165756.2cfa54c4@notabene.brown>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100524165756.2cfa54c4@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, May 24, 2010 at 04:57:56PM +1000, Neil Brown wrote:
> 
> Commit 1f36f774b22a0ceb7dd33eca626746c81a97b6a5 broke FS_REVAL_DOT semantics.
> 
> In particular, before this patch, the command
>    ls -l
> in an NFS mounted directory would always check if the directory on the server
> had changed and if so would flush and refill the pagecache for the dir.
> After this patch, the same "ls -l" will repeatedly return stale date until
> the cached attributes for the directory time out.
> 
> The following patch fixes this by ensuring the d_revalidate is called by
> do_last when "." is being looked-up.
> link_path_walk has already called d_revalidate, but in that case LOOKUP_OPEN
> is not set so nfs_lookup_verify_inode chooses not to do any validation.
> 
> The following patch restores the original behaviour.
> 
> Cc: stable@kernel.org
> Signed-off-by: NeilBrown <neilb@suse.de>

Applied, but I really don't like the way you do it; note that e.g. foo/bar/.
gets that revalidation as well, for no good reason.  If anything, shouldn't
we handle that thing in the _beginning_ of pathname resolution, not in
the end?  For now it'd do, and it's a genuine regression, but...

BTW, here's a question for nfs client folks: is it true that for any two
pathnames on _client_ resolving to pairs (mnt1, dentry) and (mnt2, dentry)
resp., nfs_devname(mnt1, dentry, ...) and nfs_devname(mnt2, dentry, ...)
should yield the strings that do not differ past the ':' (i.e. that the
only possible difference is going to be in spelling the server name)?
