From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NLM] 2.6.27 broken
Date: Thu, 5 Feb 2009 14:52:19 -0500
Message-ID: <20090205195219.GE9200@fieldses.org>
References: <20081115132831.GA11329@janus> <20081120222731.GA591@fieldses.org> <20081128112447.GA25340@janus> <20081216173923.GE16388@fieldses.org> <1229456632.6023.1.camel@tucsk> <20081216201610.GE18928@fieldses.org> <20090204233348.GD20917@fieldses.org> <20090205102153.GA29389@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Miklos Szeredi <mszeredi@suse.cz>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51325 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755701AbZBETwP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2009 14:52:15 -0500
In-Reply-To: <20090205102153.GA29389@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 05, 2009 at 11:21:53AM +0100, Frank van Maarseveen wrote:
> On Wed, Feb 04, 2009 at 06:33:48PM -0500, J. Bruce Fields wrote:
> > diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
> > index 6063a8e..763b78a 100644
> > --- a/fs/lockd/svclock.c
> > +++ b/fs/lockd/svclock.c
> > @@ -427,7 +427,7 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
> >  			goto out;
> >  		case -EAGAIN:
> >  			ret = nlm_lck_denied;
> > -			goto out;
> > +			break;
> >  		case FILE_LOCK_DEFERRED:
> >  			if (wait)
> >  				break;
> > @@ -443,6 +443,10 @@ nlmsvc_lock(struct svc_rqst *rqstp, struct nlm_file *file,
> >  			goto out;
> >  	}
> >  
> > +	ret = nlm_lck_denied;
> > +	if (!wait)
> > +		goto out;
> > +
> >  	ret = nlm_lck_blocked;
> >  
> >  	/* Append to list of blocked */
> 
> 
> fix confirmed, thanks!

Good, thanks.--b.
