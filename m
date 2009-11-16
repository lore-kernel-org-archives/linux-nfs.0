From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] mount: ECONNREFUSED is a permanent error
Date: Mon, 16 Nov 2009 13:13:56 -0500
Message-ID: <4B019664.3020002@RedHat.com>
References: <20091008173520.12619.10662.stgit@matisse.1015granger.net> <20091008173703.12619.35788.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever-MouhYhfBpPxXrIkS9f7CXA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43030 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752121AbZKPSNz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Nov 2009 13:13:55 -0500
In-Reply-To: <20091008173703.12619.35788.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/08/2009 01:37 PM, Chuck Lever wrote:
> I had assumed early on that mount.nfs should retry a refused connection.
> 
> Apparently this is not the case.  Legacy mount.nfs4 fails immediately
> if the NFS server refuses the connection.  Legacy mount.nfs and
> text-based mount.nfs both fail immediately if the rpcbind service is
> refusing connections.
> 
> So, banish ECONNREFUSED returns from mount(2) to the domain of
> permanent errors.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/stropts.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 069bdc1..0685caa 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -639,7 +639,6 @@ static int nfs_is_permanent_error(int error)
>  	switch (error) {
>  	case ESTALE:
>  	case ETIMEDOUT:
> -	case ECONNREFUSED:
>  		return 0;	/* temporary */
>  	default:
>  		return 1;	/* permanent */
> 
I'm going to hold of on this one... I just think we should 
continue to try on ECONNREFUSED errors until the retry timer pops...

steved.
