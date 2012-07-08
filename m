Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail1-relais-roc.national.inria.fr ([192.134.164.82]:58562 "EHLO
	mail1-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751742Ab2GHOmy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jul 2012 10:42:54 -0400
Date: Sun, 8 Jul 2012 16:42:52 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: question about fs/nfs/direct.c
In-Reply-To: <1341758042.3575.6.camel@lade.trondhjem.org>
Message-ID: <alpine.DEB.2.02.1207081642350.1990@hadrien>
References: <alpine.DEB.2.02.1207081113180.2436@localhost6.localdomain6> <1341758042.3575.6.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 8 Jul 2012, Myklebust, Trond wrote:

> On Sun, 2012-07-08 at 11:15 +0200, Julia Lawall wrote:
>> The following code, in the function nfs_direct_write_reschedule, looks
>> strange to me:
>>
>>          list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
>>                  if (!nfs_pageio_add_request(&desc, req)) {
>>                          nfs_list_add_request(req, &failed);
>>                          spin_lock(cinfo.lock);
>>                          dreq->flags = 0;
>>                          dreq->error = -EIO;
>>                          spin_unlock(cinfo.lock);
>>                  }
>>                  nfs_release_request(req);
>>          }
>>          nfs_pageio_complete(&desc);
>>
>>          while (!list_empty(&failed))
>>                  nfs_unlock_and_release_request(req);
>>
>> After the list_for_each_entry_safe, req is an address at some offset from
>> the list head.  So it does not seem like an appropriate argument to
>> nfs_unlock_and_release_request.
>
> Doh!... That's a bug that crept in via commit
> 1763da1234cba663b849476d451bdccac5147859 (NFS: rewrite directio write to
> use async coalesce code) and has been "polished" until it gleans several
> times with assorted cleanups...
>
> How about something like the following fix?
> 8<---------------------------------------------------------------------
> From 4035c2487f179327fae87af3477659402b797584 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Sun, 8 Jul 2012 10:24:10 -0400
> Subject: [PATCH] NFS: Fix list manipulation snafus in fs/nfs/direct.c
>
> Fix 2 bugs in nfs_direct_write_reschedule:
>
> - The request needs to be removed from the 'reqs' list before it can
>   be added to 'failed'.
> - Fix an infinite loop if the 'failed' list is non-empty.
>
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/direct.c |    6 +++++-
> 1 file changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 9a4cbfc..4825337 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -484,6 +484,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
>
> 	list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
> 		if (!nfs_pageio_add_request(&desc, req)) {
> +			nfs_list_remove_request(req);
> 			nfs_list_add_request(req, &failed);
> 			spin_lock(cinfo.lock);
> 			dreq->flags = 0;
> @@ -494,8 +495,11 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
> 	}
> 	nfs_pageio_complete(&desc);
>
> -	while (!list_empty(&failed))
> +	while (!list_empty(&failed)) {
> +		req = nfs_list_entry(failed.next);
> +		nfs_list_remove_request(req);
> 		nfs_unlock_and_release_request(req);
> +	}

It seems much more reasonable.

julia


>
> 	if (put_dreq(dreq))
> 		nfs_direct_write_complete(dreq, dreq->inode);
> -- 
> 1.7.10.4
>
>
> -- 
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
>
