Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:48401 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753708Ab3DVRSd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Apr 2013 13:18:33 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r3MHIWPt022449
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Apr 2013 13:18:32 -0400
Message-ID: <517570E7.60600@RedHat.com>
Date: Mon, 22 Apr 2013 13:18:31 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount: No longer negotiate to v2
References: <1365782736-9764-1-git-send-email-steved@redhat.com> <1365782736-9764-2-git-send-email-steved@redhat.com>
In-Reply-To: <1365782736-9764-2-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/04/13 12:05, Steve Dickson wrote:
> This patch remove the ability of negotiating to the v2
> protocol. Explicitly setting the version on the command
> line will be the only way to use v2.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed..

steved.
> ---
>  utils/mount/network.c | 13 +++++--------
>  utils/mount/stropts.c |  2 ++
>  2 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index e7bd522..4be48cd 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -155,9 +155,8 @@ static const unsigned long probe_nfs2_only[] = {
>  	0,
>  };
>  
> -static const unsigned long probe_nfs3_first[] = {
> +static const unsigned long probe_nfs3_only[] = {
>  	3,
> -	2,
>  	0,
>  };
>  
> @@ -167,10 +166,8 @@ static const unsigned long probe_mnt1_first[] = {
>  	0,
>  };
>  
> -static const unsigned long probe_mnt3_first[] = {
> +static const unsigned long probe_mnt3_only[] = {
>  	3,
> -	1,
> -	2,
>  	0,
>  };
>  
> @@ -626,7 +623,7 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
>  		probe_proto = nfs_default_proto();
>  
>  		return nfs_probe_port(sap, salen, pmap,
> -					probe_nfs3_first, probe_proto);
> +					probe_nfs3_only, probe_proto);
>  	} else
>  		return nfs_probe_port(sap, salen, pmap,
>  					probe_nfs2_only, probe_udp_only);
> @@ -653,7 +650,7 @@ static int nfs_probe_mntport(const struct sockaddr *sap, const socklen_t salen,
>  
>  	if (nfs_mount_data_version >= 4)
>  		return nfs_probe_port(sap, salen, pmap,
> -					probe_mnt3_first, probe_udp_first);
> +					probe_mnt3_only, probe_udp_first);
>  	else
>  		return nfs_probe_port(sap, salen, pmap,
>  					probe_mnt1_first, probe_udp_only);
> @@ -717,7 +714,7 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
>  	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
>  	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
>  	probe_vers = (nfs_mount_data_version >= 4) ?
> -			probe_mnt3_first : probe_mnt1_first;
> +			probe_mnt3_only : probe_mnt1_first;
>  
>  	for (; *probe_vers; probe_vers++) {
>  		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 8ee3024..1dc38ef 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -542,6 +542,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
>  			errno = EACCES;
>  		else if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
>  			errno = ETIMEDOUT;
> +		else if (rpc_createerr.cf_stat == RPC_PROGVERSMISMATCH)
> +			errno = EPROTONOSUPPORT;
>  		else if (rpc_createerr.cf_error.re_errno != 0)
>  			errno = rpc_createerr.cf_error.re_errno;
>  		return 0;
> 
