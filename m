From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS4ERR_SYMLINK  error
Date: Fri, 6 Mar 2009 16:32:34 -0500
Message-ID: <20090306213234.GB1779@fieldses.org>
References: <49AF9C28.8030603@cn.fujitsu.com> <49AFA4E4.50207@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ni Wenjuan <niwj@cn.fujitsu.com>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:49860 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbZCFVci (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Mar 2009 16:32:38 -0500
In-Reply-To: <49AFA4E4.50207@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 05, 2009 at 12:09:40PM +0200, Benny Halevy wrote:
> On Mar. 05, 2009, 11:32 +0200, Ni Wenjuan <niwj@cn.fujitsu.com> wrote:
> > the result of newpynfs test case of  LINK4a .  if you link with target directoty
> >  is a symbole file,it should get NFS4ERR_NOTDIR ,instead got NFS4ERR_SYMLINK.
> > 
> > THE LINK operation  don't list NFS4ERR_SYMLINK as valid errors in the spec. But
> > NFS4ERR_SYMLINK seems like a reasonable error.  Is this an oversight
> > in the spec, or something we need to fix?
> 
> Although NFSv4.1 adds NFS4ERR_SYMLINK to LINK's allowed errors list
> (and this might be an indication for it being an oversight in rfc3530),

The error lists in rfc3530 are known to be incomplete in some cases, so
before adding an exception like this I'd like something more.  (E.g.:
does this cause any client or application to fail?  Is there some
logical reason notdir is a more useful error than symlink?)

--b.

> NFSv4.0 doesn't allow it so this needs to be fixed.
> 
> Can you please test the following patch?
> 
> Signed-off-by: Benny Halevy <bhalevy@panasas.com>
> ---
> 
> git diff --stat -p fs/nfsd/vfs.c
>  fs/nfsd/vfs.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6e50aaa..9165b1f 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1637,6 +1637,9 @@ out_dput:
>  out_unlock:
>  	fh_unlock(ffhp);
>  out:
> +	/* nfserr_symlink returned from fh_verify is inappropriate for LINK */
> +	if (err == nfserr_symlink)
> +		err = nfserr_notdir;
>  	return err;
>  
>  out_nfserr:
> 
> 
> > 
> > 
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
