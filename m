Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:5289 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751516Ab2FSOym (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 19 Jun 2012 10:54:42 -0400
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q5JEsfp6029219
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 19 Jun 2012 10:54:41 -0400
Message-ID: <4FE0926C.2050201@RedHat.com>
Date: Tue, 19 Jun 2012 10:53:32 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: harald@redhat.com
CC: linux-nfs@vger.kernel.org, jlayton@redhat.com
Subject: Re: [PATCH] Before clearing the capability bounding set, check if
 we have the cap
References: <1339501866-18967-1-git-send-email-harald@redhat.com>
In-Reply-To: <1339501866-18967-1-git-send-email-harald@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/12/2012 07:51 AM, harald@redhat.com wrote:
> From: Harald Hoyer <harald@redhat.com>
> 
> PR_CAPBSET_DROP can return EINVAL, if an older kernel does support
> some capabilities, which are defined by CAP_LAST_CAP, which results in
> a failure of the service.
> 
> For example kernel 3.4 errors on CAP_EPOLLWAKEUP, which was newly
> introduced in 3.5.
> 
> So, for future capabilities, we clear until we get an EINVAL for
> PR_CAPBSET_READ.
Committed...

steved.

> ---
>  support/nsm/file.c      |    2 +-
>  utils/nfsdcld/nfsdcld.c |    4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/support/nsm/file.c b/support/nsm/file.c
> index 5476446..4711c2c 100644
> --- a/support/nsm/file.c
> +++ b/support/nsm/file.c
> @@ -386,7 +386,7 @@ prune_bounding_set(void)
>  	}
>  
>  	/* prune the bounding set to nothing */
> -	for (i = 0; i <= CAP_LAST_CAP; ++i) {
> +	for (i = 0; prctl(PR_CAPBSET_READ, i, 0, 0, 0) >=0 ; ++i) {
>  		ret = prctl(PR_CAPBSET_DROP, i, 0, 0, 0);
>  		if (ret) {
>  			xlog(L_ERROR, "Unable to prune capability %lu from "
> diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
> index e7af4e3..473d069 100644
> --- a/utils/nfsdcld/nfsdcld.c
> +++ b/utils/nfsdcld/nfsdcld.c
> @@ -102,8 +102,8 @@ cld_set_caps(void)
>  	}
>  
>  	/* prune the bounding set to nothing */
> -	for (i = 0; i <= CAP_LAST_CAP; ++i) {
> -		ret = prctl(PR_CAPBSET_DROP, i);
> +	for (i = 0; prctl(PR_CAPBSET_READ, i, 0, 0, 0) >= 0 ; ++i) {
> +		ret = prctl(PR_CAPBSET_DROP, i, 0, 0, 0);
>  		if (ret) {
>  			xlog(L_ERROR, "Unable to prune capability %lu from "
>  				      "bounding set: %m", i);
