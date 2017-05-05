Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48778 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752220AbdEEPHh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 May 2017 11:07:37 -0400
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8C1C581229
        for <linux-nfs@vger.kernel.org>; Fri,  5 May 2017 15:07:36 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-120-144.rdu2.redhat.com [10.10.120.144])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 521FA7FB49
        for <linux-nfs@vger.kernel.org>; Fri,  5 May 2017 15:07:36 +0000 (UTC)
Subject: Re: [PATCH] mount.nfs: Restore errno after v3 mounts on ECONNREFUSED
 errors
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
References: <20170504143704.18263-1-steved@redhat.com>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <afbc664f-b8a3-76b2-0744-2db94d195c06@RedHat.com>
Date: Fri, 5 May 2017 11:07:35 -0400
MIME-Version: 1.0
In-Reply-To: <20170504143704.18263-1-steved@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 05/04/2017 10:37 AM, Steve Dickson wrote:
> Commit 65ac59cd introduced code that tries v3 mounts
> when the the v4 mount fails with ECONNREFUSED. This
> code allows failing back to v3 to work correctly.
> 
> When the v3 mount fails the original errno value has
> been over rewritten. In this case the errno value
> needs to be restored to ECONNREFUSED.
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.
> ---
>  utils/mount/stropts.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index a9ff95d..0fbb375 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -868,7 +868,10 @@ check_result:
>  			result = nfs_try_mount_v4(mi);
>  			if (result == 0 && errno != ECONNREFUSED)
>  				goto check_result;
> -		}
> +		} else if (result == 0)
> +			/* Restore original errno with v3 failures */
> +			errno = ECONNREFUSED;
> +
>  		return result;
>  	default:
>  		return result;
> 
