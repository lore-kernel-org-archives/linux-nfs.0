Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19690 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab3LMOpA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Dec 2013 09:45:00 -0500
Date: Fri, 13 Dec 2013 09:44:58 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfsd4: break from inner lookup loop in
 nfsd4_release_lockowner on first match
Message-ID: <20131213144458.GA22937@pad.fieldses.org>
References: <52AADAF6.40700@primarydata.com>
 <1386929020-12578-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386929020-12578-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 13, 2013 at 12:03:40PM +0200, Benny Halevy wrote:
> Otherwise the lockowner may by added to "matches" more than once.

Whoops, thanks, looks right.

The lo = assignment should probably also be moved up out of this loop.

--b.

> 
> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> ---
>  fs/nfsd/nfs4state.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 0874998..84007b6 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4660,6 +4660,7 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>  			if (check_for_locks(stp->st_file, lo))
>  				goto out;
>  			list_add(&lo->lo_list, &matches);
> +			break;
>  		}
>  	}
>  	/* Clients probably won't expect us to return with some (but not all)
> -- 
> 1.8.3.1
> 
