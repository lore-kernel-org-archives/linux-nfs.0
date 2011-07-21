Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:31743 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751257Ab1GUJGJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Jul 2011 05:06:09 -0400
Subject: Re: Subject: [PATCH] Statd should always 'chdir' to its state directory.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20110721104032.38e289aa@notabene.brown>
Date: Thu, 21 Jul 2011 10:05:43 +0100
Cc: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <AF968511-9AD4-4BAB-BD05-6E21205F0EE7@oracle.com>
References: <20110721104032.38e289aa@notabene.brown>
To: NeilBrown <neilb@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jul 21, 2011, at 1:40 AM, NeilBrown wrote:

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

Seems reasonable.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
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
> 		return false;
> 	}
> 
> -	if (st.st_uid == 0) {
> -		xlog_warn("Running as root.  "
> -			"chown %s to choose different user", nsm_base_dirname);
> -		return true;
> -	}
> -
> 	if (chdir(nsm_base_dirname) == -1) {
> 		xlog(L_ERROR, "Failed to change working directory to %s: %m",
> 				nsm_base_dirname);
> 		return false;
> 	}
> 
> +	if (st.st_uid == 0) {
> +		xlog_warn("Running as root.  "
> +			"chown %s to choose different user", nsm_base_dirname);
> +		return true;
> +	}
> +
> 	/*
> 	 * If the pidfile happens to reside on NFS, dropping privileges
> 	 * will probably cause us to lose access, even though we are

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



