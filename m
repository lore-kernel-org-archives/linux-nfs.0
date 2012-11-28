Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:62973 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754742Ab2K1Q5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Nov 2012 11:57:50 -0500
Message-ID: <50B6427A.8080901@netapp.com>
Date: Wed, 28 Nov 2012 11:57:30 -0500
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 03/10] NFSD: Clean up forgetting clients
References: <1354026919-13313-1-git-send-email-bjschuma@netapp.com> <1354026919-13313-4-git-send-email-bjschuma@netapp.com> <20121128162920.GK11651@fieldses.org> <50B63D20.7050300@netapp.com> <20121128164721.GA15966@fieldses.org> <50B640B1.7060302@netapp.com> <20121128165642.GB15966@fieldses.org>
In-Reply-To: <20121128165642.GB15966@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 11/28/2012 11:56 AM, J. Bruce Fields wrote:
> On Wed, Nov 28, 2012 at 11:49:53AM -0500, Bryan Schumaker wrote:
>> On 11/28/2012 11:47 AM, J. Bruce Fields wrote:
>>> On Wed, Nov 28, 2012 at 11:34:40AM -0500, Bryan Schumaker wrote:
>>>> On 11/28/2012 11:29 AM, J. Bruce Fields wrote:
>>>>> On Tue, Nov 27, 2012 at 09:35:12AM -0500, bjschuma@netapp.com wrote:
>>>>>> From: Bryan Schumaker <bjschuma@netapp.com>
>>>>>>
>>>>>> I added in a generic for-each loop that takes a pass over the
>>>>>> client_lru list and calls some function.  The next few patches will
>>>>>> update other operations to use this function as well.  A value of 0
>>>>>> still means "forget everything that is found".
>>>>>>
>>>>>> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com> ---
>>>>>> fs/nfsd/nfs4state.c | 23 ++++++++++++++++++----- 1 file changed, 18
>>>>>> insertions(+), 5 deletions(-)
>>>>>>
>>>>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c index
>>>>>> 050a35e..07abca5 100644 --- a/fs/nfsd/nfs4state.c +++
>>>>>> b/fs/nfsd/nfs4state.c @@ -4591,19 +4591,32 @@
>>>>>> nfs4_check_open_reclaim(clientid_t *clid, bool sessions, struct
>>>>>> nfsd_net *nn)
>>>>>>  
>>>>>>  #ifdef CONFIG_NFSD_FAULT_INJECTION
>>>>>>  
>>>>>> -void nfsd_forget_clients(u64 num) +u64 nfsd_forget_client(struct
>>>>>> nfsd_net *nn, struct nfs4_client *clp, u64 max)
>>>>>
>>>>> It doesn't look like you really need nfsd_net?
>>>>
>>>> Not for this, but I find locks through the nn->ownerstr_hashtable
>>>> since the nfs4_client doesn't have a "cl_locks" list similar to
>>>> "cl_openowners" (unless there is something I'm missing...?).
>>>
>>> That's because lockowners are all reachable from openowners (e.g. see
>>> how it's done in
>>> release_openowner->unhash_openowner->release_open_stateid->unhash_open_stateid->release_stateid_lockowners.
>>> Yeah, it's a little tangled.).
>>>
>>> Alternatively you can get to the network namespace from the client
>>> (clp->net).
>>
>> Both are good to know!  I'll look at getting lockowners from openowners first.
> 
> OK.  I've also updated my for-3.8 with more of Stanislav's
> patches--doesn't look like there should be any interesting new
> conflicts, but please check.

Will do.  I'll also work in Sasha Levin's patch from yesterday while I'm updating things.

- Bryan
> 
> --b.
> 

