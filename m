Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47268 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751434AbdJLOVi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 12 Oct 2017 10:21:38 -0400
Subject: Re: [PATCH] minor exports man page typo
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
References: <20171011160243.GG25913@fieldses.org>
 <20171011160413.GH25913@fieldses.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <fb75ec0e-1334-9a17-5582-5c9f5ad62330@RedHat.com>
Date: Thu, 12 Oct 2017 10:21:37 -0400
MIME-Version: 1.0
In-Reply-To: <20171011160413.GH25913@fieldses.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 10/11/2017 12:04 PM, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> ---
>  utils/exportfs/exports.man | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
Committed...

steved.
> 
> diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
> index d8de6bec2583..db47dfdee775 100644
> --- a/utils/exportfs/exports.man
> +++ b/utils/exportfs/exports.man
> @@ -410,7 +410,7 @@ of the filesystem must be handled elsewhere.)
>  
>  .TP
>  .IR pnfs
> -This option allows enables the use of pNFS extension if protocol level
> +This option enables the use of the pNFS extension if the protocol level
>  is NFSv4.1 or higher, and the filesystem supports pNFS exports.  With
>  pNFS clients can bypass the server and perform I/O directly to storage
>  devices. The default can be explicitly requested with the
> 
