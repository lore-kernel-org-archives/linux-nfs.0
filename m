From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [NLM] 2.6.27 broken
Date: Thu, 5 Feb 2009 11:21:53 +0100
Message-ID: <20090205102153.GA29389@janus>
References: <20081115132831.GA11329@janus> <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus> <20081216173923.GE16388@fieldses.org> <1229456632.6023.1.camel@tucsk> <20081216201610.GE18928@fieldses.org> <20090204233348.GD20917@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miklos Szeredi <mszeredi@suse.cz>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:48097 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751863AbZBELZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2009 06:25:01 -0500
In-Reply-To: <20090204233348.GD20917@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 04, 2009 at 06:33:48PM -0500, J. Bruce Fields wrote:
> On Tue, Dec 16, 2008 at 03:16:10PM -0500, bfields wrote:
> > On Tue, Dec 16, 2008 at 08:43:52PM +0100, Miklos Szeredi wrote:
> > > On Tue, 2008-12-16 at 12:39 -0500, J. Bruce Fields wrote:
> > > > More precisely, it looks like this started with
> > > > 
> > > > 	bde74e4bc64415b142e "locks: add special return value for
> > > > 		asynchronous locks"
> > > > 
> > > > But I haven't had the chance to look any harder yet.  Miklos?  Is this
> > > > easy for you to reproduce?
> > > 
> > > Not immediately, at the moment I don't have NFS set up.  But if you
> > > don't beat me to it, I'll look into this.
> > 
> > OK, thanks.  I'll take another look too when I get the chance, so let me
> > know of any partial result.
> > 
> > It may just for example be returning the wrong error to the client on an
> > nlm blocking lock request, so that the client assumes the lock is gone
> > and goes away rather than waiting for a grant request.
> 
> Sorry, I've gotten a bit backlogged, but I finally got back to this.  If
> there's no objections, the following is what I intend to submit.
> 
> --b.
> 
> commit cb8b864ea6addd3a3e72fe835aafecec63f06cbd
> Author: J. Bruce Fields <bfields-+qGSg9AQ1cLTsXDwO4sDpg@public.gmane.org>
> Date:   Wed Feb 4 17:35:38 2009 -0500
> 
>     lockd: fix regression in lockd's handling of blocked locks
>     
>     If a client requests a blocking lock, is denied, then requests it again,
>     then here in nlmsvc_lock() we will call vfs_lock_file() without FL_SLEEP
>     set, because we've already queued a block and don't need the locks code
>     to do it again.
>     
>     But that means vfs_lock_file() will return -EAGAIN instead of
>     FILE_LOCK_DENIED.  So we still need to translate that -EAGAIN return
>     into a nlm_lck_blocked error in this case, and put ourselves back on
>     lockd's block list.
>     
>     The bug was introduced by bde74e4bc64415b1 "locks: add special return
>     value for asynchronous locks".
>     
>     Thanks to From: Frank van Maarseveen for the report; his original test
>     case was essentially
>     
>     	for i in `seq 30`; do flock /nfsmount/foo sleep 10 & done
>     
>     Cc: Frank van Maarseveen <frankvm@frankvm.com>
>     Cc: Miklos Szeredi <mszeredi@suse.cz>
>     Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
> 
> diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> index 6063a8e..763b78a 100644
> --- a/fs/lockd/svclock.c
> +++ b/fs/lockd/svclock.c
> @@ -427,7 +427,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
>  			goto out;
>  		case -EAGAIN:
>  			ret = nlm_lck_denied;
> -			goto out;
> +			break;
>  		case FILE_LOCK_DEFERRED:
>  			if (wait)
>  				break;
> @@ -443,6 +443,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
>  			goto out;
>  	}
>  
> +	ret = nlm_lck_denied;
> +	if (!wait)
> +		goto out;
> +
>  	ret = nlm_lck_blocked;
>  
>  	/* Append to list of blocked */


fix confirmed, thanks!

-- 
Frank
