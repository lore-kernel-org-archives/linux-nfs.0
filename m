From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH] NFSD: don't report compiled-out versions as present
Date: Fri, 14 May 2010 15:03:40 -0400
Message-ID: <20100514190340.GC17467@fieldses.org>
References: <4BED3510.80403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, NeilBrown <neilb@suse.de>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608Ab0ENTDl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 15:03:41 -0400
In-Reply-To: <4BED3510.80403@openvz.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 14, 2010 at 03:33:36PM +0400, Pavel Emelyanov wrote:
> The /proc/fs/nfsd/versions file calls nfsd_vers() to check whether
> the particular nfsd version is present/available. The problem is
> that once I turn off e.g. NFSD-V4 this call returns -1 which is
> true from the callers POV which is wrong.
> 
> The proposal is to report false in that case.
> 
> Patch is against git://linux-nfs.org/~bfields/linux:master

Thanks, applying for 2.6.35 and -stable; looks like this exists since
6658d3a7bbfd1768a7b599def47939417f0ee8ef?

--b.

> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 171699e..06b2a26 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -120,7 +120,7 @@ u32 nfsd_supported_minorversion;
>  int nfsd_vers(int vers, enum vers_op change)
>  {
>  	if (vers < NFSD_MINVERS || vers >= NFSD_NRVERS)
> -		return -1;
> +		return 0;
>  	switch(change) {
>  	case NFSD_SET:
>  		nfsd_versions[vers] = nfsd_version[vers];
> 
