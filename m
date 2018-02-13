Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:53670 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935307AbeBMOYZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 13 Feb 2018 09:24:25 -0500
Subject: Re: [PATCH 1/2] Remove nsdb_display_fedfsconnectionsec()
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
References: <20180208171330.12952.22508.stgit@manet.1015granger.net>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <cf2f1b15-c1ac-84f7-94c0-9a5c200b8fea@RedHat.com>
Date: Tue, 13 Feb 2018 09:24:24 -0500
MIME-Version: 1.0
In-Reply-To: <20180208171330.12952.22508.stgit@manet.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/08/2018 12:13 PM, Chuck Lever wrote:
> This is a display helper function that is not needed in nfs-utils
> because nfs-utils does not implement the FedFS ADMIN protocol (and
> therefore does not need to display ADMIN protocol-related security
> settings).
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
>  support/include/junction.h |    1 -
>  support/junction/display.c |   20 --------------------
>  2 files changed, 21 deletions(-)
> 
> diff --git a/support/include/junction.h b/support/include/junction.h
> index a5f3844..67cf017 100644
> --- a/support/include/junction.h
> +++ b/support/include/junction.h
> @@ -118,7 +118,6 @@ FedFsStatus	 nsdb_posix_to_path_array(const char *pathname,
>   ** Readability helpers
>   **/
>  
> -const char      *nsdb_display_fedfsconnectionsec(const FedFsConnectionSec sectype);
>  const char      *nsdb_display_fedfsstatus(const FedFsStatus status);
>  void             nsdb_print_fedfsstatus(const FedFsStatus status);
>  
> diff --git a/support/junction/display.c b/support/junction/display.c
> index 77b131f..e1e1af1 100644
> --- a/support/junction/display.c
> +++ b/support/junction/display.c
> @@ -32,26 +32,6 @@
>  #include "junction.h"
>  
>  /**
> - * Return human-readable equivalent of a FedFsConnectionSec value
> - *
> - * @param sectype FedFsConneccionSec value
> - * @return a static NUL-terminated C string
> - */
> -const char *
> -nsdb_display_fedfsconnectionsec(const FedFsConnectionSec sectype)
> -{
> -	switch (sectype) {
> -	case FEDFS_SEC_NONE:
> -		return "FEDFS_SEC_NONE";
> -	case FEDFS_SEC_TLS:
> -		return "FEDFS_SEC_TLS";
> -	default:
> -		break;
> -	}
> -	return "unrecognized security type";
> -}
> -
> -/**
>   * Return human-readable equivalent of a FedFsStatus value
>   *
>   * @param status FedFsStatus code
> 
