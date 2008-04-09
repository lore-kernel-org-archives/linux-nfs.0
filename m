From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 1/3] mount.nfs: fix retry option settings with binary
 mount options
Date: Wed, 9 Apr 2008 14:13:23 -0400
Message-ID: <20080409141323.0c594185@barsoom.rdu.redhat.com>
References: <1206822608-20154-1-git-send-email-jlayton@redhat.com>
	<1206822608-20154-2-git-send-email-jlayton@redhat.com>
	<47FD0447.9030704@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:38061 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753564AbYDISN0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 14:13:26 -0400
In-Reply-To: <47FD0447.9030704-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 09 Apr 2008 14:00:39 -0400
Steve Dickson <SteveD@redhat.com> wrote:

> 
> Jeff Layton wrote:
> > Currently nfs4mount() sets the retry value to 10000 on both fg and bg
> > mounts. It should be 2 for fg and 10000 for bg. nfsmount() sets it
> > properly, but there is a potential corner case. If someone explicitly
> > sets retry=10000 on a fg mount, then it will be reset to 2.
> > 
> > Fix this by having retry default to -1 for both flavors, and then reset if
> > needed after the mount options have been parsed.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  utils/mount/nfs4mount.c |   10 +++++++++-
> >  utils/mount/nfsmount.c  |   12 ++++++++----
> >  2 files changed, 17 insertions(+), 5 deletions(-)
> > 
> > diff --git a/utils/mount/nfs4mount.c b/utils/mount/nfs4mount.c
> > index 311e5a0..af70551 100644
> > --- a/utils/mount/nfs4mount.c
> > +++ b/utils/mount/nfs4mount.c
> > @@ -238,7 +238,7 @@ int nfs4mount(const char *spec, const char *node, int flags,
> >  	nocto = 0;
> >  	noac = 0;
> >  	unshared = 0;
> > -	retry = 10000;		/* 10000 minutes ~ 1 week */
> > +	retry = -1;
> >  
> >  	/*
> >  	 * NFSv4 specifies that the default port should be 2049
> > @@ -332,6 +332,14 @@ int nfs4mount(const char *spec, const char *node, int flags,
> >  		}
> >  	}
> >  
> > +	/* if retry is still -1, then it wasn't set via an option */
> > +	if (retry == -1) {
> > +		if (bg)
> > +			retry = 10000;	/* 10000 mins == ~1 week */
> > +		else
> > +			retry = 2;	/* 2 min default on fg mounts */
> > +	}
> > +
> >  	data.flags = (soft ? NFS4_MOUNT_SOFT : 0)
> >  		| (intr ? NFS4_MOUNT_INTR : 0)
> >  		| (nocto ? NFS4_MOUNT_NOCTO : 0)
> > diff --git a/utils/mount/nfsmount.c b/utils/mount/nfsmount.c
> > index ff0ff93..27c46a7 100644
> > --- a/utils/mount/nfsmount.c
> > +++ b/utils/mount/nfsmount.c
> > @@ -571,7 +571,7 @@ nfsmount(const char *spec, const char *node, int flags,
> >  #endif
> >  
> >  	bg = 0;
> > -	retry = 10000;		/* 10000 minutes ~ 1 week */
> > +	retry = -1;
> >  
> >  	memset(mnt_pmap, 0, sizeof(*mnt_pmap));
> >  	mnt_pmap->pm_prog = MOUNTPROG;
> > @@ -585,9 +585,13 @@ nfsmount(const char *spec, const char *node, int flags,
> >  		goto fail;
> >  	if (!nfsmnt_check_compat(nfs_pmap, mnt_pmap))
> >  		goto fail;
> > -	
> > -	if (retry == 10000 && !bg)
> > -		retry = 2; /* reset for fg mounts */
> > +
> > +	if (retry == -1) {
> > +		if (bg)
> > +			retry = 10000;	/* 10000 mins == ~1 week*/
> > +		else
> > +			retry = 2;	/* 2 min default on fg mounts */
> > +	}
> >  
> >  #ifdef NFS_MOUNT_DEBUG
> >  	printf(_("rsize = %d, wsize = %d, timeo = %d, retrans = %d\n"),
> 
> Jeff, 
> 
> I believe all thats needed is to add the same code nfsmount() uses
> reset retry into nfs4mount(). Something like:
> 
> --- a/utils/mount/nfs4mount.c
> +++ b/utils/mount/nfs4mount.c
> @@ -332,6 +332,9 @@ int nfs4mount(const char *spec, const char *node, int flags,
>                 }
>         }
>  
> +       if (retry == 10000 && !bg)
> +               retry = 2; /* reset for fg mounts */
> +
>         data.flags = (soft ? NFS4_MOUNT_SOFT : 0)
>                 | (intr ? NFS4_MOUNT_INTR : 0)
>                 | (nocto ? NFS4_MOUNT_NOCTO : 0)
> 
> or missing something...
> 
> 
> steved.

That shouldn't be needed. With this patch, retry defaults to -1. After
we parse the options if it's still -1, then we reset it to whatever the
default should be.

Note the deltas to nfs4mount() above...

-- 
Jeff Layton <jlayton@redhat.com>
