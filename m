From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 01/31] nfsd41: slots are freed with session
Date: Thu, 30 Apr 2009 12:12:55 +0300
Message-ID: <49F96B97.8050204@panasas.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:13164 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751405AbZD3JNX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 05:13:23 -0400
In-Reply-To: <1240938005-23778-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 28, 2009, 19:59 +0300, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> The session and slots are allocated all in one piece.

This patch should go into 2.6.30, right?

Benny

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index e82a518..42ebcb3 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -582,7 +582,6 @@ free_session(struct kref *kref)
>  		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
>  		nfsd4_release_respages(e->ce_respages, e->ce_resused);
>  	}
> -	kfree(ses->se_slots);
>  	kfree(ses);
>  }
>  
