Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f49.google.com ([74.125.82.49]:37187 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab3J3OHt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Oct 2013 10:07:49 -0400
Received: by mail-wg0-f49.google.com with SMTP id x12so1388542wgg.16
        for <linux-nfs@vger.kernel.org>; Wed, 30 Oct 2013 07:07:48 -0700 (PDT)
Message-ID: <527112AA.3090104@primarydata.com>
Date: Wed, 30 Oct 2013 16:07:38 +0200
From: Benny Halevy <bhalevy@primarydata.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/7] nfsd4: need to destroy revoked delegations in destroy_client
References: <526F81DE.6060704@primarydata.com> <1383039552-27209-1-git-send-email-bhalevy@primarydata.com> <20131029150414.GS31322@fieldses.org> <20131029160210.GW31322@fieldses.org>
In-Reply-To: <20131029160210.GW31322@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-10-29 18:02, J. Bruce Fields wrote:
> On Tue, Oct 29, 2013 at 11:04:14AM -0400, bfields wrote:
>> Whoops, yes, looks like a good fix.
>>
>> I'm not convinced of the need for the recall_lock here for reasons given
>> before.  Could you just drop the recall_lock here and resend?
> 
> Actually never mind I've done that on my local tree.  I'll wait to push
> it out till you've had a chance to object.

no objection. thanks.

> 
> --b.
> 
>>
>> --b.
>>
>> On Tue, Oct 29, 2013 at 11:39:12AM +0200, Benny Halevy wrote:
>>> [use list_splice_init]
>>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>>> ---
>>>  fs/nfsd/nfs4state.c | 7 +++++++
>>>  1 file changed, 7 insertions(+)
>>>
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index a403502..a66b0ad 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -1129,6 +1129,13 @@ static struct nfs4_client *alloc_client(struct xdr_netobj name)
>>>  		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
>>>  		destroy_delegation(dp);
>>>  	}
>>> +	spin_lock(&recall_lock);
>>> +	list_splice_init(&clp->cl_revoked, &reaplist);
>>> +	spin_unlock(&recall_lock);
>>> +	while (!list_empty(&reaplist)) {
>>> +		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
>>> +		destroy_revoked_delegation(dp);
>>> +	}
>>>  	while (!list_empty(&clp->cl_openowners)) {
>>>  		oo = list_entry(clp->cl_openowners.next, struct nfs4_openowner, oo_perclient);
>>>  		release_openowner(oo);
>>> -- 
>>> 1.8.3.1
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
