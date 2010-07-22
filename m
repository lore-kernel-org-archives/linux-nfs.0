Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19739 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758780Ab0GVMgo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Jul 2010 08:36:44 -0400
Date: Thu, 22 Jul 2010 08:36:29 -0400
From: Jeff Layton <jlayton@redhat.com>
To: <Staubach_Peter@emc.com>
Cc: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
 (try #4)
Message-ID: <20100722083629.337e95ae@barsoom.rdu.redhat.com>
In-Reply-To: <BF3BB6D12298F54B89C8DCC1E4073D8001E488B3@CORPUSMX50A.corp.emc.com>
References: <1279718501-6834-1-git-send-email-jlayton@redhat.com>
	<20100721201437.GD28123@fieldses.org>
	<BF3BB6D12298F54B89C8DCC1E4073D8001E488B3@CORPUSMX50A.corp.emc.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 22 Jul 2010 07:59:39 -0400
<Staubach_Peter@emc.com> wrote:

> 
> 
> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of J. Bruce Fields
> Sent: Wednesday, July 21, 2010 4:15 PM
> To: Jeff Layton
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: [PATCH 5/5] nfsd: just keep single lockd reference for nfsd
> (try #4)
> 
> On Wed, Jul 21, 2010 at 09:21:41AM -0400, Jeff Layton wrote:
> > Right now, nfsd keeps a lockd reference for each socket that it has
> > open. This is unnecessary and complicates the error handling on
> startup
> > and shutdown. Change it to just do a lockd_up when starting the first
> > nfsd thread just do a single lockd_down when taking down the last nfsd
> > thread. Because of the strange way the sv_count is handled, this
> > requires an extra flag to tell whether the nfsd_serv holds a reference
> > for lockd or not.
> > 
> > This patch also changes the error handling in nfsd_create_serv a bit
> > too. There doesn't seem to be any need to reset the nfssvc_boot time
> if
> > the nfsd startup failed.
> > 
> > Note though that this does change the user-visible behavior slightly.
> > Today, a lockd_up is done whenever a socket fd is handed off to the
> > kernel. With this change, lockd is brought up as soon as the first
> > thread is started. I think this makes more sense. If there are
> problems
> > in userspace, the old scheme had the possibility to start lockd long
> > before any nfsd threads were started. This patch helps minimize that
> > possibility.
> 
> The nfs4 state startup has the same problem that I think lockd_up was
> designed to solve.
> 
> There's a bunch of stuff that only makes sense to run when nrthreads
> transitions from zero to nonzero, or vice-versa; so, if we stick them
> all in one helper function I think it's cleaner and solves another minor
> startup bug.  Something like this?
> 
> (Incremental on top of your last patch, with some noise due to moving
> stuff around to avoid forward references.  I'll clean these up and
> resend.)
> 
> Then we could also get rid of some of the individual flags (nfs4_init at
> least), I think.
> 
> --b.
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 2e15db0..fd2524b 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -25,7 +25,6 @@
>  extern struct svc_program	nfsd_program;
>  static int			nfsd(void *vrqstp);
>  struct timeval			nfssvc_boot;
> -static bool			nfsd_lockd_up;
>  
>  /*
>   * nfsd_mutex protects nfsd_serv -- both the pointer itself and the
> members
> @@ -181,16 +180,79 @@ int nfsd_nrthreads(void)
>  	return rv;
>  }
>  
> +static int nfsd_init_socks(int port)
> +{
> +	int error;
> +	if (!list_empty(&nfsd_serv->sv_permsocks))
> +		return 0;
> +
> +	error = svc_create_xprt(nfsd_serv, "udp", PF_INET, port,
> +					SVC_SOCK_DEFAULTS);
> +	if (error < 0)
> +		return error;
> +
> +	error = svc_create_xprt(nfsd_serv, "tcp", PF_INET, port,
> +					SVC_SOCK_DEFAULTS);
> +	if (error < 0)
> +		return error;
> 
> Doesn't this leave something dangling if svc_create_xprt for "udp"
> succeeds,
> but svc_create_xprt for "tcp" fails?
> 
> 		ps
> 

I think you're right. Note however that Bruce is just moving this
function around to avoid a forward declaration.

FWIW, I don't think this code is really used anymore -- at least
not with any reasonably modern rpc.nfsd program. Those all "hand off"
sockets explicitly to the kernel before bringing up threads, and the
sv_permsocks check short circuits that code.

So, this really amounts to a legacy interface and I'm not sure that we
want to go to any lengths to fix it.

-- 
Jeff Layton <jlayton@redhat.com>
