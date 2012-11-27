Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:4471 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755511Ab2K0RhK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 12:37:10 -0500
Message-ID: <50B4FA43.6010902@netapp.com>
Date: Tue, 27 Nov 2012 12:37:07 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Sasha Levin <sasha.levin@oracle.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: prevent NULL ptr derefs on fault injection
References: <1354033871-25815-1-git-send-email-sasha.levin@oracle.com> <20121127170136.GE27142@fieldses.org> <50B4F302.8010304@netapp.com>
In-Reply-To: <50B4F302.8010304@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/27/2012 12:06 PM, Bryan Schumaker wrote:
> On 11/27/2012 12:01 PM, J. Bruce Fields wrote:
>> On Tue, Nov 27, 2012 at 11:31:11AM -0500, Sasha Levin wrote:
>>> A recent patch series has moved hashtable initialization to when the net
>>> struct is initialized.
>>>
>>> When injecting faults, we tried accessing the hashtables even if the struct
>>> wasn't really initialized (nfsd wasn't in use) - this caused a NULL ptr
>>> deref.
>>
>> Thanks, adding Bryan to cc.--b.
> 
> I was just looking over this :).  Unfortunately, this patch changes code that my most recent patch set removes so my patches will need to change again if this goes in first.  I'm looking for the best place to put this check to avoid having to change each of the forget_something() functions.
> 
> - Bryan

This works on top of my most recent patches:

diff --git a/fs/nfsd/fault_inject.c b/fs/nfsd/fault_inject.c
index 699de07..235162a 100644
--- a/fs/nfsd/fault_inject.c
+++ b/fs/nfsd/fault_inject.c
@@ -76,6 +76,9 @@ static void nfsd_inject_set_client(struct nfsd_fault_inject_op *op,
        u64 count;
        struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
 
+       if (!nfsd_netns_ready(nn))
+               return;
+
        nfs4_lock_state();
        clp = nfsd_find_client(nn, addr, addr_size);
        if (clp) {
diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 227b93e..c5806a57 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -83,5 +83,8 @@ struct nfsd_net {
        struct delayed_work laundromat_work;
 };
 
+/* Simple check to find out if a given net was properly initialized */
+#define nfsd_netns_ready(nn) ((nn)->sessionid_hashtbl)
+
 extern int nfsd_net_id;
 #endif /* __NFSD_NETNS_H__ */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b32414e..84295d9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4739,6 +4739,9 @@ u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client
        u64 count = 0;
        struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
 
+       if (!nfsd_netns_ready(nn))
+               return 0;
+
        list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
                count += func(nn, clp, max - count);
                if ((max != 0) && (count >= max))


>>
>>>
>>> A simple test would be:
>>>
>>> 	echo 1 > /sys/kernel/debug/nfsd/forget_locks
>>>
>>> Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
>>> ---
>>>  fs/nfsd/netns.h     | 3 +++
>>>  fs/nfsd/nfs4state.c | 9 +++++++++
>>>  2 files changed, 12 insertions(+)
>>>
>>> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
>>> index 227b93e..c5806a57 100644
>>> --- a/fs/nfsd/netns.h
>>> +++ b/fs/nfsd/netns.h
>>> @@ -83,5 +83,8 @@ struct nfsd_net {
>>>  	struct delayed_work laundromat_work;
>>>  };
>>>  
>>> +/* Simple check to find out if a given net was properly initialized */
>>> +#define nfsd_netns_ready(nn) ((nn)->sessionid_hashtbl)
>>> +
>>>  extern int nfsd_net_id;
>>>  #endif /* __NFSD_NETNS_H__ */
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index e75872f..0e7428c 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -4598,6 +4598,9 @@ void nfsd_forget_clients(u64 num)
>>>  	int count = 0;
>>>  	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
>>>  
>>> +	if (!nfsd_netns_ready(nn))
>>> +		return;
>>> +
>>>  	nfs4_lock_state();
>>>  	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
>>>  		expire_client(clp);
>>> @@ -4643,6 +4646,9 @@ void nfsd_forget_locks(u64 num)
>>>  	int count;
>>>  	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
>>>  
>>> +	if (!nfsd_netns_ready(nn))
>>> +		return;
>>> +
>>>  	nfs4_lock_state();
>>>  	count = nfsd_release_n_owners(num, false, release_lockowner_sop, nn);
>>>  	nfs4_unlock_state();
>>> @@ -4655,6 +4661,9 @@ void nfsd_forget_openowners(u64 num)
>>>  	int count;
>>>  	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
>>>  
>>> +	if (!nfsd_netns_ready(nn))
>>> +		return;
>>> +
>>>  	nfs4_lock_state();
>>>  	count = nfsd_release_n_owners(num, true, release_openowner_sop, nn);
>>>  	nfs4_unlock_state();
>>> -- 
>>> 1.8.0
>>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

