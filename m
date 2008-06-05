From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Subject: Re: [PATCH 2/4] knfsd: remove special handling for SIGHUP
Date: Thu, 05 Jun 2008 10:59:19 +1000
Message-ID: <48473A67.4060307@melbourne.sgi.com>
References: <1212591796-22144-1-git-send-email-jlayton@redhat.com> <1212591796-22144-2-git-send-email-jlayton@redhat.com> <1212591796-22144-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, neilb@suse.de
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:50542 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752752AbYFEBDK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Jun 2008 21:03:10 -0400
In-Reply-To: <1212591796-22144-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton wrote:
> The special handling for SIGHUP in knfsd is a holdover from much
> earlier versions of Linux where reloading the export table was
> more expensive. That facility is not really needed anymore and
> to my knowledge, is seldom-used.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>   
Acked-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> @@ -234,10 +226,9 @@ int nfsd_create_serv(void)
>  	}
>  
>  	atomic_set(&nfsd_busy, 0);
> -	nfsd_serv = svc_create_pooled(&nfsd_program,
> -				      nfsd_max_blksize,
> -				      nfsd_last_thread,
> -				      nfsd, SIG_NOCLEAN, THIS_MODULE);
> +	nfsd_serv = svc_create_pooled(&nfsd_program, nfsd_max_blksize,
> +				      nfsd_last_thread, nfsd, SIGINT,
> +				      THIS_MODULE);
>   
Now that there's no special interpretation of signals, you could
probably also remove the `sig' argument to svc_create_pooled() and the
svc_serv->sv_kill_signal field.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.

