Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36030 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932275AbbFDU11 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Jun 2015 16:27:27 -0400
Date: Thu, 4 Jun 2015 16:27:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>,
        linux-nfs@vger.kernel.org, Vasily Isaenko <vasily.isaenko@oracle.com>,
        "SHUANG.QIU" <shuang.qiu@oracle.com>
Subject: Re: nfsd: EACCES vs EPERM on utime()/utimes() calls
Message-ID: <20150604202725.GE5209@fieldses.org>
References: <556C73AE.4090900@oracle.com>
 <20150601212317.GF26972@fieldses.org>
 <556DD52D.5040405@oracle.com>
 <557047E2.10804@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <557047E2.10804@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 04, 2015 at 08:43:14PM +0800, Kinglong Mee wrote:
> On 6/3/2015 12:09 AM, Stanislav Kholmanskikh wrote:
> > On 06/02/2015 12:23 AM, bfields@fieldses.org wrote:
> >> On Mon, Jun 01, 2015 at 06:01:02PM +0300, Stanislav Kholmanskikh wrote:
> >>> Hello.
> >>>
> >>> As the man page for utime/utimes states [1], EPERM is returned if
> >>> the second argument of utime/utimes is not NULL and:
> >>>   * the caller's effective user id does not match the owner of the file
> >>>   * the caller does not have write access to the file
> >>>   * the caller is not privileged
> >>>
> >>> However, I don't see this behavior with NFS, I see EACCES is
> >>> generated instead.
> >>
> >> Agreed that it's probably a server bug.  (Have you run across a case
> >> where this makes a difference?)
> > 
> > Thank you.
> > 
> > No, I've not seen such a real-word scenario.
> > 
> > I have these LTP test cases failing:
> > 
> > * https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/utime/utime06.c
> > * https://github.com/linux-test-project/ltp/blob/master/testcases/kernel/syscalls/utimes/utimes01.c
> > 
> > and it makes me a bit nervous :)
> > 
> >>
> >> Looking at nfsd_setattr()....  The main work is done by notify_change(),
> >> which is probably doing the right thing.  But before that there's an
> >> fh_verify()--looks like that is expected to fail in your case.  I bet
> >> that's the cause.
> 
> Yes, it is.
> 
> nfsd do the permission checking before notify_change() as,
> 
> /* This assumes  NFSD_MAY_{READ,WRITE,EXEC} == MAY_{READ,WRITE,EXEC} */
> err = inode_permission(inode, acc & (MAY_READ|MAY_WRITE|MAY_EXEC));
> 
> return -EACCES for non-owner user.
> 
> > 
> > I doubt I can fix it by myself (at least quickly). So I am happy if anyone more experienced will look at it as well :)
> > 
> > Anyway, if nobody is interested, I'll give it a try, but later.
> 
> Here is a diff patch for this problem, please try testing.
> If okay, I will send an official patch.
> 
> Note: must apply the following patch first in the url,
> http://git.linux-nfs.org/?p=bfields/linux.git;a=commitdiff;h=cc265089ce1b176dde963c74b53593446ee7f99a

We could do that if we have to.

I wonder if we could instead skip the fh_verify's inode_permission call
entirely?  Most callers of fh_verify don't need the inode_permission
call at all as far as I can tell, because the following vfs operation
does permission checking already.

We still need some nfs-specific checking, I guess (e.g. to make sure we
aren't allowing setattr on a read-only export of a writeable mount), but
the inode_permission itself I think we can usually skip.

Andreas Gruenbacher has also been complaining that the redundant
inode_permission calls make the richacl work more difficult, I can't
remember why exactly.

--b.

> 
> thanks,
> Kinglong Mee
> -------------------------------------------------------------
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 84d770b..2533088 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -407,10 +371,23 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
>  	bool		get_write_count;
>  	int		size_change = 0;
>  
> -	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME | ATTR_SIZE))
> +	if (iap->ia_valid & ATTR_SIZE) {
>  		accmode |= NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE;
> -	if (iap->ia_valid & ATTR_SIZE)
>  		ftype = S_IFREG;
> +	}
> +
> +	/*
> +	 * According to utimes_common(),
> +	 *
> +	 * If times is NULL (or both times are UTIME_NOW),
> +	 * then we need to check permissions, because
> +	 * inode_change_ok() won't do it.
> +	 */
> +	if (iap->ia_valid & (ATTR_ATIME | ATTR_MTIME)) {
> +		accmode |= NFSD_MAY_OWNER_OVERRIDE;
> +		if (!(iap->ia_valid & (ATTR_ATIME_SET | ATTR_MTIME_SET)))
> +			accmode |= NFSD_MAY_WRITE;
> +	}
>  
>  	/* Callers that do fh_verify should do the fh_want_write: */
>  	get_write_count = !fhp->fh_dentry;
