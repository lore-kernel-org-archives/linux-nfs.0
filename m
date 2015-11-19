Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40574 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932082AbbKSUGx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Nov 2015 15:06:53 -0500
Date: Thu, 19 Nov 2015 15:06:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1 31/38] nfs: replace d_add with d_splice_alias in
 atomic_open
Message-ID: <20151119200651.GB8506@fieldses.org>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
 <1447761180-4250-32-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1447761180-4250-32-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 17, 2015 at 06:52:53AM -0500, Jeff Layton wrote:
> From: Peng Tao <tao.peng@primarydata.com>
> 
> It's a trival change but follows knfsd export document that asks
> for d_splice_alias during lookup.

This is a bug even before you start exporting, isn't it?

OK, I see, in the atomic_open case we're probably only dealing with a
positive dentry for a regular file at this point, in which case
d_splice_alias is really just d_add....

I'm not sure this patch is really necessary, then.

--b.


> 
> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
> ---
>  fs/nfs/dir.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index ce5a21861074..a4df1137878e 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1534,7 +1534,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
>  		switch (err) {
>  		case -ENOENT:
>  			d_drop(dentry);
> -			d_add(dentry, NULL);
> +			d_splice_alias(NULL, dentry);
>  			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
>  			break;
>  		case -EISDIR:
> -- 
> 2.4.3
