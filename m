Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30767 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751304Ab1GUT0I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 15:26:08 -0400
Message-ID: <4E287D48.3020605@RedHat.com>
Date: Thu, 21 Jul 2011 15:26:00 -0400
From: Steve Dickson <SteveD@redhat.com>
To: NeilBrown <neilb@suse.de>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Subject: [PATCH] Statd should always 'chdir' to its state directory.
References: <20110721104032.38e289aa@notabene.brown>
In-Reply-To: <20110721104032.38e289aa@notabene.brown>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/20/2011 08:40 PM, NeilBrown wrote:
> 
> Subject: [PATCH] Statd should always 'chdir' to its state directory.
> 
> As statd can be started by 'mount' which can sometimes be run by a
> normal user, the current-working-directory could be anything.  In
> partcular it could be in a mounted filesystem.  As 'statd' continues
> running as a daemon it could keep prevent that filesystem from being
> unmounted.
> 
> statd does currently 'chdir' to the state directory, but only if the
> state directory is not owned by root.  This is wrong - it should check
> for root after the chdir, not before.
> 
> So swap the two if statements around.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
Committed...

steved.

> 
> --
> looks like this regression slipped in around January 2010 with the big libnsm clean up.
> -NB
> 
> 
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 98b47bf..a12c753 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -395,18 +395,18 @@ nsm_drop_privileges(const int pidfd)
>  		return false;
>  	}
>  
> -	if (st.st_uid == 0) {
> -		xlog_warn("Running as root.  "
> -			"chown %s to choose different user", nsm_base_dirname);
> -		return true;
> -	}
> -
>  	if (chdir(nsm_base_dirname) == -1) {
>  		xlog(L_ERROR, "Failed to change working directory to %s: %m",
>  				nsm_base_dirname);
>  		return false;
>  	}
>  
> +	if (st.st_uid == 0) {
> +		xlog_warn("Running as root.  "
> +			"chown %s to choose different user", nsm_base_dirname);
> +		return true;
> +	}
> +
>  	/*
>  	 * If the pidfile happens to reside on NFS, dropping privileges
>  	 * will probably cause us to lose access, even though we are
