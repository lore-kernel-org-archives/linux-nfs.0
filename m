Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:42253 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755110Ab1LNNmV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 08:42:21 -0500
Message-ID: <4EE8A7BA.6050406@netapp.com>
Date: Wed, 14 Dec 2011 08:42:18 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Only reinitilize the recall_lru list under the
 recall lock
References: <1323812158-5183-1-git-send-email-bjschuma@netapp.com> <20111213221209.GA30904@fieldses.org>
In-Reply-To: <20111213221209.GA30904@fieldses.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue Dec 13 17:12:09 2011, J. Bruce Fields wrote:
> On Tue, Dec 13, 2011 at 04:35:58PM -0500, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> unhash_delegation() will grab the recall lock before calling
>> list_del_init() in each of these places.  This patch removes the
>> redundant calls.
>
> Looks right, thanks.  (How did you happen across this?)

I was looking over the fault injection stuff to see if I can figure out 
where an occasional oops was coming from.  It seems to happen when I 
forget delegations, so I was looking at how other functions release 
delegations to see if there was something I missed.  The oops doesn't 
happen often enough for me to know if this patch fixes it yet, though.

- Bryan
>
> --b.
>
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfsd/nfs4state.c |    3 ---
>>  1 files changed, 0 insertions(+), 3 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 6ab6779..43d5c22 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -1058,7 +1058,6 @@ expire_client(struct nfs4_client *clp)
>>  	spin_unlock(&recall_lock);
>>  	while (!list_empty(&reaplist)) {
>>  		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
>> -		list_del_init(&dp->dl_recall_lru);
>>  		unhash_delegation(dp);
>>  	}
>>  	while (!list_empty(&clp->cl_openowners)) {
>> @@ -3125,7 +3124,6 @@ nfs4_laundromat(void)
>>  	spin_unlock(&recall_lock);
>>  	list_for_each_safe(pos, next, &reaplist) {
>>  		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
>> -		list_del_init(&dp->dl_recall_lru);
>>  		unhash_delegation(dp);
>>  	}
>>  	test_val = nfsd4_lease;
>> @@ -4667,7 +4665,6 @@ __nfs4_state_shutdown(void)
>>  	spin_unlock(&recall_lock);
>>  	list_for_each_safe(pos, next, &reaplist) {
>>  		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
>> -		list_del_init(&dp->dl_recall_lru);
>>  		unhash_delegation(dp);
>>  	}
>>  
>> -- 
>> 1.7.8
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


