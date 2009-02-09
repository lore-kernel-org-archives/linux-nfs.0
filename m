From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: Use lowercase names of quota functions
Date: Mon, 9 Feb 2009 17:37:00 -0500
Message-ID: <20090209223700.GL13636@fieldses.org>
References: <1234215051-10809-1-git-send-email-jack@suse.cz> <20090209220738.GB10838@duck.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
To: Jan Kara <jack@suse.cz>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:55776 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbZBIWgy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 17:36:54 -0500
In-Reply-To: <20090209220738.GB10838-pwKtmJkCtMINMLpHRKhSow@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 09, 2009 at 11:07:38PM +0100, Jan Kara wrote:
> On Mon 09-02-09 22:30:51, Jan Kara wrote:
> > Use lowercase names of quota functions instead of old uppercase ones.
> > 
> > CC: bfields@fieldses.org
> > CC: neilb@suse.de
> > Signed-off-by: Jan Kara <jack@suse.cz>
>   And I should add that this patch is queued in my quota tree and I plan to
> send it to Linus in the next merge window (i.e. for 2.6.30-rc1).

Fine by me, thanks.--b.

> 
> 									Honza
> > ---
> >  fs/nfsd/vfs.c |    4 ++--
> >  1 files changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 6e50aaa..ad38fc9 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -356,7 +356,7 @@ nfsd_setattr(struct svc_rqst *rqstp, struct svc_fh *fhp, struct iattr *iap,
> >  			put_write_access(inode);
> >  			goto out_nfserr;
> >  		}
> > -		DQUOT_INIT(inode);
> > +		vfs_dq_init(inode);
> >  	}
> >  
> >  	/* sanitize the mode change */
> > @@ -723,7 +723,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
> >  		else
> >  			flags = O_WRONLY|O_LARGEFILE;
> >  
> > -		DQUOT_INIT(inode);
> > +		vfs_dq_init(inode);
> >  	}
> >  	*filp = dentry_open(dget(dentry), mntget(fhp->fh_export->ex_path.mnt),
> >  			    flags, cred);
> > -- 
> > 1.6.0.2
> > 
