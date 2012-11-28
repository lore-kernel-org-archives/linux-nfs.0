Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:23727 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753259Ab2K1Qem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 11:34:42 -0500
Message-ID: <50B63D20.7050300@netapp.com>
Date: Wed, 28 Nov 2012 11:34:40 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 03/10] NFSD: Clean up forgetting clients
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com> <1354026919-13313-4-git-send-email-bjschuma@netapp.com> <20121128162920.GK11651@fieldses.org>
In-Reply-To: <20121128162920.GK11651@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/28/2012 11:29 AM, J. Bruce Fields wrote:
> On Tue, Nov 27, 2012 at 09:35:12AM -0500, bjschuma@netapp.com wrote:
>> From: Bryan Schumaker <bjschuma@netapp.com>
>>
>> I added in a generic for-each loop that takes a pass over the client_lru
>> list and calls some function.  The next few patches will update other
>> operations to use this function as well.  A value of 0 still means "forget
>> everything that is found".
>>
>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>> ---
>>  fs/nfsd/nfs4state.c | 23 ++++++++++++++++++-----
>>  1 file changed, 18 insertions(+), 5 deletions(-)
>>
>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>> index 050a35e..07abca5 100644
>> --- a/fs/nfsd/nfs4state.c
>> +++ b/fs/nfsd/nfs4state.c
>> @@ -4591,19 +4591,32 @@ nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct nfsd_net *nn)
>>  
>>  #ifdef CONFIG_NFSD_FAULT_INJECTION
>>  
>> -void nfsd_forget_clients(u64 num)
>> +u64 nfsd_forget_client(struct nfsd_net *nn, struct nfs4_client *clp, u64 max)
> 
> It doesn't look like you really need nfsd_net?

Not for this, but I find locks through the nn->ownerstr_hashtable since the nfs4_client doesn't have a "cl_locks" list similar to "cl_openowners" (unless there is something I'm missing...?).  I figured I would introduce the function with the nfsd_net pointer early, rather than change it in the next patch.

I suppose I could have also put the locks patch first...

- Bryan

> 
> --b.
> 
>> +{
>> +	nfsd4_client_record_remove(clp);
>> +	expire_client(clp);
>> +	return 1;
>> +}
>> +
>> +static u64 nfsd_for_n_state(u64 max, u64 (*func)(struct nfsd_net *, struct nfs4_client *, u64))
>>  {
>>  	struct nfs4_client *clp, *next;
>> -	int count = 0;
>> +	u64 count = 0;
>>  	struct nfsd_net *nn = net_generic(current->nsproxy->net_ns, nfsd_net_id);
>>  
>>  	list_for_each_entry_safe(clp, next, &nn->client_lru, cl_lru) {
>> -		expire_client(clp);
>> -		if (++count == num)
>> +		count += func(nn, clp, max - count);
>> +		if ((max != 0) && (count >= max))
>>  			break;
>>  	}
>>  
>> -	printk(KERN_INFO "NFSD: Forgot %d clients", count);
>> +	return count;
>> +}
>> +
>> +void nfsd_forget_clients(u64 num)
>> +{
>> +	u64 count = nfsd_for_n_state(num, nfsd_forget_client);
>> +	printk(KERN_INFO "NFSD: Forgot %llu clients", count);
>>  }
>>  
>>  static void release_lockowner_sop(struct nfs4_stateowner *sop)
>> -- 
>> 1.8.0.1
>>

