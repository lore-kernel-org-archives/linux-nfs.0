From: Andy Adamson <andros@netapp.com>
Subject: Re: [PATCH 01/31] nfsd41: slots are freed with session
Date: Thu, 30 Apr 2009 09:13:19 -0400
Message-ID: <E822BDE1-D1FF-41F4-A40A-95F5B6D475FF@netapp.com>
References: <1240938005-23778-1-git-send-email-andros@netapp.com> <49F96B97.8050204@panasas.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: bfields@fieldses.org, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27429 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753117AbZD3NNW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2009 09:13:22 -0400
In-Reply-To: <49F96B97.8050204@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

yes, you're right - it prevents an oops on server shutdown.

-->Andy

On Apr 30, 2009, at 5:12 AM, Benny Halevy wrote:

> On Apr. 28, 2009, 19:59 +0300, andros@netapp.com wrote:
>> From: Andy Adamson <andros@netapp.com>
>>
>> The session and slots are allocated all in one piece.
>
> This patch should go into 2.6.30, right?
>
> Benny
>
>>
>> Signed-off-by: Andy Adamson <andros@netapp.com>
>> ---
>> fs/nfsd/nfs4state.c |    1 -
>> 1 files changed, 0 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index e82a518..42ebcb3 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -582,7 +582,6 @@ free_session(struct kref *kref)
>> 		struct nfsd4_cache_entry *e = &ses->se_slots[i].sl_cache_entry;
>> 		nfsd4_release_respages(e->ce_respages, e->ce_resused);
>> 	}
>> -	kfree(ses->se_slots);
>> 	kfree(ses);
>> }
>>

