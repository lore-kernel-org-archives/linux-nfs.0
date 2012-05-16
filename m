Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40279 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131Ab2EPVQW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 17:16:22 -0400
Date: Wed, 16 May 2012 17:16:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Weston Andros Adamson <dros@netapp.com>
Cc: bjschuma@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd: return 0 on reads of fault injection files
Message-ID: <20120516211621.GE20487@fieldses.org>
References: <1336678270-791-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1336678270-791-1-git-send-email-dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 10, 2012 at 03:31:10PM -0400, Weston Andros Adamson wrote:
> debugfs read operations were returning the contents of an uninitialized u64.

Thanks, applied.

> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> I found this while working on (forthcoming) fault injection tests for 
> CB_PATH_DOWN.

Did you ever confirm whether the latest nfsd is setting that flag when
it should be?

--b.

> 
>  fs/nfsd/fault_inject.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
> index 46b7696..ab81144 100644
> --- a/fs/nfsd/fault_inject.c
> +++ b/fs/nfsd/fault_inject.c
> @@ -62,6 +62,7 @@ static int nfsd_inject_set(void *op_ptr, u64 val)
>  
>  static int nfsd_inject_get(void *data, u64 *val)
>  {
> +	*val = 0;
>  	return 0;
>  }
>  
> -- 
> 1.7.4.4
> 
