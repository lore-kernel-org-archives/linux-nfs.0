From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 01/26] statd: Replace note() with xlog() in rpc.statd
Date: Wed, 14 Oct 2009 12:57:55 -0400
Message-ID: <20091014165755.GA20968@fieldses.org>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net> <20091013145416.2424.12787.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, chris.mason@oracle.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41062 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934932AbZJNQ5m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 12:57:42 -0400
In-Reply-To: <20091013145416.2424.12787.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 13, 2009 at 10:54:16AM -0400, Chuck Lever wrote:
> diff --git a/utils/statd/misc.c b/utils/statd/misc.c
> index 7256291..44af30e 100644
> --- a/utils/statd/misc.c
> +++ b/utils/statd/misc.c
> @@ -29,8 +29,7 @@ xmalloc (size_t size)
>      return ((void *)NULL);
>  
>    if (!(ptr = malloc (size)))
> -    /* SHIT!  SHIT!  SHIT! */
> -    die ("malloc failed");
> +    xlog_err ("malloc failed");

Minor comment, no need to fix now, but: with the name "die" it was a lot
more obvious that this function never returned.

Also future work (not a problem with this patch): it's irritating that
we have long-running daemons dying on memory allocation failures.
Wouldn't it be better if they failed just the current operation and
tried to keep going?

--b.
