Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:15540 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915Ab2EWNf0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 May 2012 09:35:26 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Andy Adamson <androsadamson@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 4/4] NFSv4.1 do not release page on commit mismatch
Date: Wed, 23 May 2012 13:35:07 +0000
Message-ID: <9BA765BC-E489-4858-BDD2-5EB9C5BD8174@netapp.com>
References: <1337688569-1515-1-git-send-email-andros@netapp.com>
 <1337688569-1515-5-git-send-email-andros@netapp.com>
 <1337703865.4269.21.camel@lade.trondhjem.org>
 <4D70BD9B-4F81-4E57-8689-DCE6F8B1A1C2@netapp.com>
 <1337708765.4269.26.camel@lade.trondhjem.org>
 <CAHVgHyV_mm6234=1CmS8+1Lcp0A1yGBRmhLX31m1cjGkFZJLcw@mail.gmail.com>
 <1337719244.4269.30.camel@lade.trondhjem.org>
In-Reply-To: <1337719244.4269.30.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 22, 2012, at 4:40 PM, Myklebust, Trond wrote:

> On Tue, 2012-05-22 at 14:07 -0400, Andy Adamson wrote:
>> On Tue, May 22, 2012 at 1:46 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Tue, 2012-05-22 at 16:30 +0000, Adamson, Andy wrote:
>>>> On May 22, 2012, at 12:24 PM, Myklebust, Trond wrote:
>>>> 
>>>>> On Tue, 2012-05-22 at 08:09 -0400, andros@netapp.com wrote:
>>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>> 
>>>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>>>> ---
>>>>>> fs/nfs/write.c |    2 ++
>>>>>> 1 files changed, 2 insertions(+), 0 deletions(-)
>>>>>> 
>>>>>> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>>>>>> index e6fe3d6..c7295de 100644
>>>>>> --- a/fs/nfs/write.c
>>>>>> +++ b/fs/nfs/write.c
>>>>>> @@ -1555,6 +1555,8 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
>>>>>>           /* We have a mismatch. Write the page again */
>>>>>>           dprintk(" mismatch\n");
>>>>>>           nfs_mark_request_dirty(req);
>>>>>> +          nfs_unlock_request(req);
>>>>>> +          continue;
>>>>>>   next:
>>>>>>           nfs_unlock_and_release_request(req);
>>>>>>   }
>>>>> 
>>>>> What is this patch trying to fix? As far as I can see it will lead to a
>>>>> reference leak.
>>>> 
>>>> The release of the page drops the refcount to zero. Since it is a mismatch, we want to continue to use the page, so nfs_page_find_request_locked is called we get the WARNING in kref_get, and an Oops in various places in pnfs_update_layout.
>>>> 
>>>> Here is the output of added printk's.
>>>> 
>>>> -->Andy
>>>> 
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.988921] NFS:       commit (0:35/2 4096@184320)
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.988923]  mismatch req ffff880042dbb800
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.988927] nfs_release_request WB req ffff880042dbb800 wb_kref 1
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.988932] put_lseg: lseg ffff880042d95380 ref 4 valid 0
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.988945] nfs_page_find_request_locked req ffff88003e033800
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.988949] nfs_page_find_request_locked WB req ffff88003e033800 wb_kref 0
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.988953] ------------[ cut here ]------------
>>>> May 21 18:25:33 fedora-64-2 kernel: [  152.989082] WARNING: at include/linux/kref.h:41 kref_get+0x20/0x2c [nfs]()
>>> 
>>> Are these commit-to-ds requests?
>> 
>> Yes
> 
> OK, so how about the following fix:



Yep - works just fine.  Thanks!

-->Andy

> 
> 8<---------------------------------------------------------------
> From 53b8ee346463946f88b3e1639d688c384df1166c Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date: Tue, 22 May 2012 16:36:27 -0400
> Subject: [PATCH] NFSv4.1: Fix a bad reference count issue in the pNFS commit
> code
> 
> filelayout_scan_commit_lists needs to bump the reference count on
> the struct nfs_page just like nfs_scan_commit_list().
> 
> Reported-by: Andy Adamson <andros@netapp.com>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> fs/nfs/nfs4filelayout.c |    1 +
> 1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
> index 474c630..33849d3 100644
> --- a/fs/nfs/nfs4filelayout.c
> +++ b/fs/nfs/nfs4filelayout.c
> @@ -1106,6 +1106,7 @@ transfer_commit_list(struct list_head *src, struct list_head *dst,
> 	list_for_each_entry_safe(req, tmp, src, wb_list) {
> 		if (!nfs_lock_request(req))
> 			continue;
> +		kref_get(&req->wb_kref);
> 		if (cond_resched_lock(cinfo->lock))
> 			list_safe_reset_next(req, tmp, wb_list);
> 		nfs_request_remove_commit_list(req, cinfo);
> -- 
> 1.7.7.6
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

