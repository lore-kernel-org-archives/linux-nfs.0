Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:45034 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab3GJB0V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 21:26:21 -0400
Date: Tue, 9 Jul 2013 21:26:25 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org,
        Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
        David Howells <dhowells@redhat.com>,
        Tyler Hicks <tyhicks@canonical.com>,
        Dustin Kirkland <dustin.kirkland@gazzang.com>
Subject: Re: [PATCH 12/12] locks: break delegations on any attribute
 modification
Message-ID: <20130709212625.7fdfc6e1@corrin.poochiereds.net>
In-Reply-To: <20130709211911.GL32574@pad.fieldses.org>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
	<1372882356-14168-13-git-send-email-bfields@redhat.com>
	<20130709093047.0096f061@tlielax.poochiereds.net>
	<20130709205101.GK32574@pad.fieldses.org>
	<20130709211911.GL32574@pad.fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Jul 2013 17:19:12 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> On Tue, Jul 09, 2013 at 04:51:01PM -0400, J. Bruce Fields wrote:
> > On Tue, Jul 09, 2013 at 09:30:47AM -0400, Jeff Layton wrote:
> > > On Wed,  3 Jul 2013 16:12:36 -0400
> > > "J. Bruce Fields" <bfields@redhat.com> wrote:
> > > 
> > > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > > 
> > > > NFSv4 uses leases to guarantee that clients can cache metadata as well
> > > > as data.
> > > > 
> ...
> > > Isn't it possible we'll need to break a delegation on truncate()?
> > 
> > In the truncate case, the caller called break_lease, and in the
> > ftruncate case it's called with a write open, and the open already broke
> > any leases or delegations.
> > 
> > Might need a comment--could I get away with just this?:
> > 
> >  	mutex_lock(&dentry->d_inode->i_mutex);
> > +	/* NULL is safe: any delegations have already been broken: */
> >  	ret = notify_change(dentry, &newattrs, NULL);
> >  	mutex_unlock(&dentry->d_inode->i_mutex);
> >  	return ret;
> > 
> > I also added something to the notify_change kerneldoc: "passing NULL is
> > fine for callers holding the file open for write, as there can be no
> > conflicting delegation in that case."
> 
> Another question is whether it's really worth dropping locks and
> retrying in this case.
> 
> We could instead do the following.
> 
> --b.
> 
> commit 40a4fd613034cd3f242ec11e5ecd44f9a83ab39d
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Tue Sep 20 17:19:26 2011 -0400
> 
>     locks: break delegations on any attribute modification
>     
>     NFSv4 uses leases to guarantee that clients can cache metadata as well
>     as data.
>     
>     Note unlike link, unlink, and rename, we don't bother dropping locks and
>     retrying.  In the other cases we're holding a directory mutex, hence
>     blocking operations (even lookups) on the same directory.  In this case
>     we're holding only the i_mutex on this file, so the impact of an
>     unresponsive client is limited to this file.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/attr.c b/fs/attr.c
> index 1449adb..a2c1d04 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -243,6 +243,9 @@ int notify_change(struct dentry * dentry, struct iattr * attr)
>  	error = security_inode_setattr(dentry, attr);
>  	if (error)
>  		return error;
> +	error = break_deleg_wait(inode);
> +	if (error)
> +		return error;
>  
>  	if (inode->i_op->setattr)
>  		error = inode->i_op->setattr(dentry, attr);


I guess the question is whether there are operations that require the
i_mutex but that don't require the delegation recall to have finished.

-- 
Jeff Layton <jlayton@redhat.com>
