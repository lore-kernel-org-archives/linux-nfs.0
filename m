Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f171.google.com ([74.125.82.171]:39099 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753102Ab3J3OCv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Oct 2013 10:02:51 -0400
Received: by mail-we0-f171.google.com with SMTP id t60so1323111wes.16
        for <linux-nfs@vger.kernel.org>; Wed, 30 Oct 2013 07:02:50 -0700 (PDT)
Message-ID: <52711187.10202@primarydata.com>
Date: Wed, 30 Oct 2013 16:02:47 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/7] nfsd4: fix recall_lock use in unhash_delegation
References: <526F81DE.6060704@primarydata.com> <1383039544-27157-1-git-send-email-bhalevy@primarydata.com> <20131029144658.GR31322@fieldses.org>
In-Reply-To: <20131029144658.GR31322@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-29 16:46, J. Bruce Fields wrote:
> On Tue, Oct 29, 2013 at 11:39:04AM +0200, Benny Halevy wrote:
>> Access to dp->dl_perclnt must be synchronized by the recall_lock
> 
> Are you sure?  recall_lock is for stuff that's needed in the delegation
> break callback (nfsd_break_deleg_cb() and any of the subsequent callback
> handling).  I don't think that includes dl_perclnt.

I was mislead by the fact that destroy_client and nfs4_state_shutdown_net
care to acquire the recall_lock for traversing the clp->cl_delegations
and nn->del_recall_lru lists, respectively.

Now nfs4_state_shutdown_net, although its comment says it should be
called with the state lock held (SHOULD or should, or should it be MUST? :)
It doesn't seem like nfsd_shutdown_net acquires the state lock.

Therefore, we either need to grab the state lock in nfs4_state_shutdown_net
which adds yet another problem to fix, or access dl_perclnt always under the
spin lock.

Benny

> 
> --b.
> 
>>
>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>> ---
>>  fs/nfsd/nfs4state.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index a90949a..a403502 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -436,8 +436,8 @@ static void unhash_stid(struct nfs4_stid *s)
>>  static void
>>  unhash_delegation(struct nfs4_delegation *dp)
>>  {
>> -	list_del_init(&dp->dl_perclnt);
>>  	spin_lock(&recall_lock);
>> +	list_del_init(&dp->dl_perclnt);
>>  	list_del_init(&dp->dl_perfile);
>>  	list_del_init(&dp->dl_recall_lru);
>>  	spin_unlock(&recall_lock);
>> -- 
>> 1.8.3.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
