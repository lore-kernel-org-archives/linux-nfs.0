Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:51642 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422755Ab2CPPCo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 16 Mar 2012 11:02:44 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q2GF2iOp006580
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 16 Mar 2012 11:02:44 -0400
Message-ID: <4F635610.9050105@RedHat.com>
Date: Fri, 16 Mar 2012 11:02:40 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] nfsd: Bump up the default to 8 nprocs
References: <1331905256-21639-1-git-send-email-steved@redhat.com>
In-Reply-To: <1331905256-21639-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 03/16/2012 09:40 AM, Steve Dickson wrote:
> When the nproc argument is not given the rpc.nfsd
> a default number of processes is created. This
> patch bumps that default up from 1 to 8.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/nfsd/nfsd.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
> index 8bc5d3a..2a3f5cc 100644
> --- a/utils/nfsd/nfsd.c
> +++ b/utils/nfsd/nfsd.c
> @@ -27,6 +27,10 @@
>  #include "nfssvc.h"
>  #include "xlog.h"
>  
> +#ifndef NFSD_NPROC
> +#define NFSD_NPROC 8
> +#endif
> +
>  static void	usage(const char *);
>  
>  static struct option longopts[] =
> @@ -90,7 +94,7 @@ nfsd_enable_protos(unsigned int *proto4, unsigned int *proto6)
>  int
>  main(int argc, char **argv)
>  {
> -	int	count = 1, c, error = 0, portnum = 0, fd, found_one;
> +	int	count = NFSD_NPROC, c, error = 0, portnum = 0, fd, found_one;
>  	char *p, *progname, *port;
>  	char *haddr = NULL;
>  	int	socket_up = 0;
