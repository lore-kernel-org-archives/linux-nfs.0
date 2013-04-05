Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:41398 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161562Ab3DEOoM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 10:44:12 -0400
Message-ID: <515EE2D0.8080006@parallels.com>
Date: Fri, 5 Apr 2013 18:42:24 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 3/4] nfsd4: make del_recall_lru per-network-namespace
References: <1365170886-2267-1-git-send-email-bfields@redhat.com> <1365170886-2267-4-git-send-email-bfields@redhat.com> <20130405140952.GA2335@fieldses.org>
In-Reply-To: <20130405140952.GA2335@fieldses.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

05.04.2013 18:09, J. Bruce Fields пишет:
> On Fri, Apr 05, 2013 at 10:08:05AM -0400, J. Bruce Fields wrote:
>> From: "J. Bruce Fields" <bfields@redhat.com>
>>
>> If nothing else this simplifies the nfs4_state_shutdown_net logic a tad.
>
> Stanislav, my one worry is that there was some reason you didn't do
> this, that I've overlooked....
>

Hmm... Currently I can't remember a reason, why I didn't do that...
This looks reasonable. Thanks!

BTW, maybe recall_lock should be containerised as well?


> --b.
>
>>
>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>> ---
>>   fs/nfsd/netns.h     |  1 +
>>   fs/nfsd/nfs4state.c | 15 +++++++--------
>>   2 files changed, 8 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>> index 1051beb..849a7c3 100644
>> --- a/fs/nfsd/netns.h
>> +++ b/fs/nfsd/netns.h
>> @@ -80,6 +80,7 @@ struct nfsd_net {
>>   	 */
>>   	struct list_head client_lru;
>>   	struct list_head close_lru;
>> +	struct list_head del_recall_lru;
>>
>>   	struct delayed_work laundromat_work;
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 26a03fa..aae9304 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -225,8 +225,6 @@ opaque_hashval(const void *ptr, int nbytes)
>>   	return x;
>>   }
>>
>> -static struct list_head del_recall_lru;
>> -
>>   static void nfsd4_free_file(struct nfs4_file *f)
>>   {
>>   	kmem_cache_free(file_slab, f);
>> @@ -2583,6 +2581,9 @@ out:
>>
>>   static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
>>   {
>> +	struct nfs4_client *clp = dp->dl_stid.sc_client;
>> +	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
>> +
>>   	/* We're assuming the state code never drops its reference
>>   	 * without first removing the lease.  Since we're in this lease
>>   	 * callback (and since the lease code is serialized by the kernel
>> @@ -2590,7 +2591,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
>>   	 * it's safe to take a reference: */
>>   	atomic_inc(&dp->dl_count);
>>
>> -	list_add_tail(&dp->dl_recall_lru, &del_recall_lru);
>> +	list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
>>
>>   	/* only place dl_time is set. protected by lock_flocks*/
>>   	dp->dl_time = get_seconds();
>> @@ -3254,7 +3255,7 @@ nfs4_laundromat(struct nfsd_net *nn)
>>   		expire_client(clp);
>>   	}
>>   	spin_lock(&recall_lock);
>> -	list_for_each_safe(pos, next, &del_recall_lru) {
>> +	list_for_each_safe(pos, next, &nn->del_recall_lru) {
>>   		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
>>   		if (net_generic(dp->dl_stid.sc_client->net, nfsd_net_id) != nn)
>>   			continue;
>> @@ -4810,7 +4811,6 @@ struct nfs4_client *nfsd_find_client(struct sockaddr_storage *addr, size_t addr_
>>   void
>>   nfs4_state_init(void)
>>   {
>> -	INIT_LIST_HEAD(&del_recall_lru);
>>   }
>>
>>   /*
>> @@ -4874,6 +4874,7 @@ static int nfs4_state_create_net(struct net *net)
>>   	nn->unconf_name_tree = RB_ROOT;
>>   	INIT_LIST_HEAD(&nn->client_lru);
>>   	INIT_LIST_HEAD(&nn->close_lru);
>> +	INIT_LIST_HEAD(&nn->del_recall_lru);
>>   	spin_lock_init(&nn->client_lock);
>>
>>   	INIT_DELAYED_WORK(&nn->laundromat_work, laundromat_main);
>> @@ -4986,10 +4987,8 @@ nfs4_state_shutdown_net(struct net *net)
>>
>>   	INIT_LIST_HEAD(&reaplist);
>>   	spin_lock(&recall_lock);
>> -	list_for_each_safe(pos, next, &del_recall_lru) {
>> +	list_for_each_safe(pos, next, &nn->del_recall_lru) {
>>   		dp = list_entry (pos, struct nfs4_delegation, dl_recall_lru);
>> -		if (dp->dl_stid.sc_client->net != net)
>> -			continue;
>>   		list_move(&dp->dl_recall_lru, &reaplist);
>>   	}
>>   	spin_unlock(&recall_lock);
>> --
>> 1.7.11.7
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Best regards,
Stanislav Kinsbursky
