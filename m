Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25384 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750901AbaCHPUU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 8 Mar 2014 10:20:20 -0500
Message-ID: <531B3530.4060704@RedHat.com>
Date: Sat, 08 Mar 2014 10:20:16 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Neil Brown <neilb@suse.de>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] nfsd: add -r and --rdma options to request rdma service.
References: <20140220063616.6548.42556.stgit@notabene.brown> <20140220063648.6548.10041.stgit@notabene.brown>
In-Reply-To: <20140220063648.6548.10041.stgit@notabene.brown>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Neil,

This part did not apply cleanly 

On 02/20/2014 01:36 AM, Neil Brown wrote:
> void
>  nfssvc_setvers(unsigned int ctlbits, int minorvers[])
>  {
> diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
> index 2bbd3d30f92a..bb7fccee7c19 100644
> --- a/utils/nfsd/nfssvc.h
> +++ b/utils/nfsd/nfssvc.h
> @@ -24,5 +24,6 @@ void	nfssvc_mount_nfsdfs(char *progname);
>  int	nfssvc_inuse(void);
>  int	nfssvc_set_sockets(const int family, const unsigned int protobits,
>  			   const char *host, const char *port);
> +int	nfssvc_set_rdmaport(const char *port);
>  void	nfssvc_setvers(unsigned int ctlbits, int minorvers4[]);
^^^ this interface is different that the one I have in my tree

The one I have is 
void    nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, unsigned int minorvers4set);

No biggie but I'm just wandering if I'm missing a patch... 

steved.
>  int	nfssvc_threads(unsigned short port, int nrservs);
