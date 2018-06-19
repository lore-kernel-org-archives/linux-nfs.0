Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36313 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1030228AbeFSQ4k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Jun 2018 12:56:40 -0400
Subject: Re: [PATCH] exports: document change to "insecure" export option
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20180614133238.GA24594@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <e698f0ad-0c7f-a527-5c55-f09cd88ca2e2@RedHat.com>
Date: Tue, 19 Jun 2018 12:56:39 -0400
MIME-Version: 1.0
In-Reply-To: <20180614133238.GA24594@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/14/2018 09:32 AM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We're changing the kernel to allow gss requests from high ports even
> when "secure" is set.
> 
> If the change gets backported to distro kernels, the kernel version may
> be an imperfect predictor of the behavior, but I think it's the best we
> can do.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Committed.... 

steved.
> ---
>  utils/exportfs/exports.man | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index 4f95f3a2197e..e3a16f6b276a 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -131,10 +131,12 @@ this way are ro, rw, no_root_squash, root_squash, and all_squash.
>  understands the following export options:
>  .TP
>  .IR secure
> -This option requires that requests originate on an Internet port less
> -than IPPORT_RESERVED (1024). This option is on by default. To turn it
> -off, specify
> +This option requires that requests not using gss originate on an
> +Internet port less than IPPORT_RESERVED (1024). This option is on by default.
> +To turn it off, specify
>  .IR insecure .
> +(NOTE: older kernels (before upstream kernel version 4.17) enforced this
> +requirement on gss requests as well.)
>  .TP
>  .IR rw
>  Allow both read and write requests on this NFS volume. The
> 
