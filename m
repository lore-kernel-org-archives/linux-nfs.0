Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:35254 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab3DLRA7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Apr 2013 13:00:59 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH] mount: No longer negotiate to v2
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1365782736-9764-2-git-send-email-steved@redhat.com>
Date: Fri, 12 Apr 2013 13:00:53 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <2A4E5E3D-FCC3-4E16-80CA-77E079EF860F@oracle.com>
References: <1365782736-9764-1-git-send-email-steved@redhat.com> <1365782736-9764-2-git-send-email-steved@redhat.com>
To: Steve Dickson <steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 12, 2013, at 12:05 PM, Steve Dickson <steved@redhat.com> wrote:

> This patch remove the ability of negotiating to the v2
> protocol. Explicitly setting the version on the command
> line will be the only way to use v2.

Just curious: is there a way to do this using the mount configuration file?


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> utils/mount/network.c | 13 +++++--------
> utils/mount/stropts.c |  2 ++
> 2 files changed, 7 insertions(+), 8 deletions(-)
> 
> diff --git a/utils/mount/network.c b/utils/mount/network.c
> index e7bd522..4be48cd 100644
> --- a/utils/mount/network.c
> +++ b/utils/mount/network.c
> @@ -155,9 +155,8 @@ static const unsigned long probe_nfs2_only[] = {
> 	0,
> };
> 
> -static const unsigned long probe_nfs3_first[] = {
> +static const unsigned long probe_nfs3_only[] = {
> 	3,
> -	2,
> 	0,
> };
> 
> @@ -167,10 +166,8 @@ static const unsigned long probe_mnt1_first[] = {
> 	0,
> };
> 
> -static const unsigned long probe_mnt3_first[] = {
> +static const unsigned long probe_mnt3_only[] = {
> 	3,
> -	1,
> -	2,
> 	0,
> };
> 
> @@ -626,7 +623,7 @@ static int nfs_probe_nfsport(const struct sockaddr *sap, const socklen_t salen,
> 		probe_proto = nfs_default_proto();
> 
> 		return nfs_probe_port(sap, salen, pmap,
> -					probe_nfs3_first, probe_proto);
> +					probe_nfs3_only, probe_proto);
> 	} else
> 		return nfs_probe_port(sap, salen, pmap,
> 					probe_nfs2_only, probe_udp_only);
> @@ -653,7 +650,7 @@ static int nfs_probe_mntport(const struct sockaddr *sap, const socklen_t salen,
> 
> 	if (nfs_mount_data_version >= 4)
> 		return nfs_probe_port(sap, salen, pmap,
> -					probe_mnt3_first, probe_udp_first);
> +					probe_mnt3_only, probe_udp_first);
> 	else
> 		return nfs_probe_port(sap, salen, pmap,
> 					probe_mnt1_first, probe_udp_only);
> @@ -717,7 +714,7 @@ int nfs_probe_bothports(const struct sockaddr *mnt_saddr,
> 	memcpy(&save_nfs, nfs_pmap, sizeof(save_nfs));
> 	memcpy(&save_mnt, mnt_pmap, sizeof(save_mnt));
> 	probe_vers = (nfs_mount_data_version >= 4) ?
> -			probe_mnt3_first : probe_mnt1_first;
> +			probe_mnt3_only : probe_mnt1_first;
> 
> 	for (; *probe_vers; probe_vers++) {
> 		nfs_pmap->pm_vers = mntvers_to_nfs(*probe_vers);
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 8ee3024..1dc38ef 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -542,6 +542,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
> 			errno = EACCES;
> 		else if (rpc_createerr.cf_stat == RPC_TIMEDOUT)
> 			errno = ETIMEDOUT;
> +		else if (rpc_createerr.cf_stat == RPC_PROGVERSMISMATCH)
> +			errno = EPROTONOSUPPORT;
> 		else if (rpc_createerr.cf_error.re_errno != 0)
> 			errno = rpc_createerr.cf_error.re_errno;
> 		return 0;
> -- 
> 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




