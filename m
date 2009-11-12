From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfsd: NFS fails to come up then the network is down.
Date: Thu, 12 Nov 2009 14:28:52 -0500
Message-ID: <20091112142852.51721c7e@barsoom.rdu.redhat.com>
References: <4AFC60AA.4030502@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58734 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752570AbZKLT2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 12 Nov 2009 14:28:48 -0500
Received: from int-mx04.intmail.prod.int.phx2.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.17])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id nACJSs15027565
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2009 14:28:54 -0500
In-Reply-To: <4AFC60AA.4030502-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 12 Nov 2009 14:23:22 -0500
Steve Dickson <SteveD@redhat.com> wrote:

> In some recent testing it appears nfsd fails to come up
> when an non-loopback network interface is not configured. 
> This patch solves the problem.
> 
> steved.
> 
> commit 2905358524c0835311501bad04c521479b0525ff
> Author: Steve Dickson <steved@redhat.com>
> Date:   Thu Nov 12 14:16:12 2009 -0500
> 
>     Remove the AI_ADDRCONFIG hint flag to getaddrinfo() when it's
>     call by nfsd to set up the file descriptors that are
>     sent to the kernel. The flag causes the getaddrinfo()
>     to fail, with EAI_NONAME, when there is not a non-loopback
>     network interface configured.
>     
>     Signed-off-by: Steve Dickson <steved@redhat.com>
> 
> diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
> index 12d3253..b8028bb 100644
> --- a/utils/nfsd/nfssvc.c
> +++ b/utils/nfsd/nfssvc.c
> @@ -212,7 +212,7 @@ int
>  nfssvc_set_sockets(const int family, const unsigned int protobits,
>  		   const char *host, const char *port)
>  {
> -	struct addrinfo hints = { .ai_flags = AI_PASSIVE | AI_ADDRCONFIG };
> +	struct addrinfo hints = { .ai_flags = AI_PASSIVE };
>  
>  	hints.ai_family = family;
>  

Patch looks correct. I think AI_ADDRCONFIG is superfluous here. nfsd
already limits what sockets it tries to hand off to the kernel based on
the contents of /etc/netconfig so there should be no problem removing
that flag.

Acked-by: Jeff Layton <jlayton@redhat.com>
