Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:42809 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106AbbCWPM6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Mar 2015 11:12:58 -0400
Date: Mon, 23 Mar 2015 11:12:57 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, hch@infradead.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] nfsd: fix use-after-free oops in v4.0 (and some
 other minor cleanups)
Message-ID: <20150323151257.GA15183@fieldses.org>
References: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1427122424-8078-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 23, 2015 at 10:53:41AM -0400, Jeff Layton wrote:
> After staring at this code for a _long_ time, I think I've finally found
> the source of the use-after-free oops that HCH spotted. The first patch
> in this series should fix that.  The other two patches are just cleanups
> that I generated while staring at the code.
> 
> The first one obviously needs to go into v4.0 (and stable) ASAP. The
> other two can wait for v4.1.

Zowie, thanks!  It's a relief to have this one found....--b.

> 
> Jeff Layton (3):
>   nfsd: return correct openowner when there is a race to put one in the
>     hash
>   nfsd: remove bogus setting of status in nfsd4_process_open2
>   nfsd: remove unused status arg to nfsd4_cleanup_open_state
> 
>  fs/nfsd/nfs4proc.c  | 2 +-
>  fs/nfsd/nfs4state.c | 5 ++---
>  fs/nfsd/xdr4.h      | 2 +-
>  3 files changed, 4 insertions(+), 5 deletions(-)
> 
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
