From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Make sm-notify faster if there are no servers to notify
Date: Fri, 5 Dec 2008 11:38:24 -0500
Message-ID: <20081205163824.GA29227@fieldses.org>
References: <20081029173750.GD31936@fieldses.org> <1225302305994@dmwebmail.dmwebmail.chezphil.org> <20081029184153.GE31936@fieldses.org> <5AB39614-D03F-43DF-BCD2-2B2501A79D65@oracle.com> <20081029211145.GE1406@fieldses.org> <49183A12.7010707@RedHat.com> <20081204211057.GC9593@fieldses.org> <18744.41310.635618.148281@notabene.brown> <20081205035803.GC15115@fieldses.org> <49392C14.7000709@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Chuck Lever <chuck.lever@oracle.com>,
	Phil Endecott <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>,
	linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:52423 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750845AbYLEQig (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Dec 2008 11:38:36 -0500
In-Reply-To: <49392C14.7000709-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 05, 2008 at 08:26:44AM -0500, Steve Dickson wrote:
> J. Bruce Fields wrote:
> > 
> >> I think it would still be valuable to replace the 'sync' with two
> >> 'fsync's, one of the file, one on the directory.
> > 
> > Sure, may as well.--b.
> > 
> Something similar to this:
> 
> diff -up nfs-utils/utils/statd/sm-notify.c.orig nfs-utils/utils/statd/sm-notify.c
> --- nfs-utils/utils/statd/sm-notify.c.orig	2008-11-17 15:06:13.000000000 -0500
> +++ nfs-utils/utils/statd/sm-notify.c	2008-12-05 08:21:52.000000000 -0500
> @@ -211,12 +211,6 @@ usage:		fprintf(stderr,
>  	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
>  	get_hosts(_SM_BAK_PATH);
>  
> -	/* If there are not hosts to notify, just exit */
> -	if (!hosts) {
> -		nsm_log(LOG_DEBUG, "No hosts to notify; exiting");
> -		return 0;
> -	}

This was still a huge boot-time win in the common case, so now that
we've committed to it I'd rather not regress.  Let's just skip the
sync()s/fsncy()s in the !hosts case--that looks to me like the simplest
correct solution for now.

> -
>  	/* Get and update the NSM state. This will call sync() */
>  	nsm_state = nsm_get_state(opt_update_state);
>  	set_kernel_nsm_state(nsm_state);
> @@ -694,6 +688,7 @@ nsm_get_state(int update)
>  {
>  	char		newfile[PATH_MAX];
>  	int		fd, state;
> +	DIR 	*fp;
>  
>  	if ((fd = open(_SM_STATE_PATH, O_RDONLY)) < 0) {
>  		if (!opt_quiet) {
> @@ -730,13 +725,16 @@ nsm_get_state(int update)
>  				"Failed to write state to %s", newfile);
>  			exit(1);
>  		}
> +		fsync(fd);
>  		close(fd);
> +		fp = opendir(_SM_STATE_PATH);

Also, I think you meant to:

		fsync(fp);
		close(fp);

?

--b.

>  		if (rename(newfile, _SM_STATE_PATH) < 0) {
>  			nsm_log(LOG_ERR,
>  				"Cannot create %s: %m", _SM_STATE_PATH);
>  			exit(1);
>  		}
> -		sync();
> 
> If so, I'll make it happen...
> 
> steved.
