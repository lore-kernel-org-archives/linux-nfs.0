Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51324 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755070AbbJUPvI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Oct 2015 11:51:08 -0400
Date: Wed, 21 Oct 2015 11:51:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v6 01/19] nfsd: move include of state.h from trace.c to
 trace.h
Message-ID: <20151021155106.GB27929@fieldses.org>
References: <1445362432-18869-1-git-send-email-jeff.layton@primarydata.com>
 <1445362432-18869-2-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1445362432-18869-2-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 20, 2015 at 01:33:34PM -0400, Jeff Layton wrote:
> Any file which includes trace.h will need to include state.h, even if
> they aren't using any state tracepoints. Ensure that we include any
> headers that might be needed in trace.h instead of relying on the
> *.c files to have the right ones.

Applied, thanks.--b.

> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> ---
>  fs/nfsd/trace.c | 2 --
>  fs/nfsd/trace.h | 2 ++
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfsd/trace.c b/fs/nfsd/trace.c
> index 82f89070594c..90967466a1e5 100644
> --- a/fs/nfsd/trace.c
> +++ b/fs/nfsd/trace.c
> @@ -1,5 +1,3 @@
>  
> -#include "state.h"
> -
>  #define CREATE_TRACE_POINTS
>  #include "trace.h"
> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
> index c668520c344b..0befe762762b 100644
> --- a/fs/nfsd/trace.h
> +++ b/fs/nfsd/trace.h
> @@ -9,6 +9,8 @@
>  
>  #include <linux/tracepoint.h>
>  
> +#include "state.h"
> +
>  DECLARE_EVENT_CLASS(nfsd_stateid_class,
>  	TP_PROTO(stateid_t *stp),
>  	TP_ARGS(stp),
> -- 
> 2.4.3
