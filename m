From: "William A. (Andy) Adamson" <androsadamson@gmail.com>
Subject: Re: [pnfs] [PATCH 05/29] nfsd41: create_session cache hold client
	reference
Date: Fri, 24 Apr 2009 10:06:42 -0400
Message-ID: <89c397150904240706l7c642f0ds5d6b997117fd84c@mail.gmail.com>
References: <1240504988-9572-1-git-send-email-andros@netapp.com>
	 <1240504988-9572-2-git-send-email-andros@netapp.com>
	 <1240504988-9572-3-git-send-email-andros@netapp.com>
	 <1240504988-9572-4-git-send-email-andros@netapp.com>
	 <1240504988-9572-5-git-send-email-andros@netapp.com>
	 <1240504988-9572-6-git-send-email-andros@netapp.com>
	 <20090423232825.GK1906@fieldses.org>
	 <1D363F53-7E7A-472C-8176-BB8F33A94BDB@netapp.com>
	 <20090424140245.GB15038@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:56037 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757648AbZDXOGn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Apr 2009 10:06:43 -0400
Received: by rv-out-0506.google.com with SMTP id f9so1018539rvb.1
        for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2009 07:06:42 -0700 (PDT)
In-Reply-To: <20090424140245.GB15038@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 24, 2009 at 10:02 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Fri, Apr 24, 2009 at 09:52:56AM -0400, Andy Adamson wrote:
>>
>> On Apr 23, 2009, at 7:28 PM, J. Bruce Fields wrote:
>>
>>> On Thu, Apr 23, 2009 at 12:42:44PM -0400, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>>
>>>> expire_client can be called on a confirmed or unconfirmed client
>>>> while
>>>> processing the create session operation and accessing the clientid
>>>> slot.
>>>
>>> I don't understand--isn't all that under the state lock for now?
>>
>> Yes it is. I now see that expire_client is also always called under the
>> state lock. Fair enough, this patch can be dropped.
>
> OK, thanks.  Note this wouldn't be quite right even in the absence of a
> lock, because there'd be nothing to guarantee that conf is still good at
> the time we do the atomic_inc(&conf->cl_count) (what happens if someone
> frees conf before we even get there?
>
> The way this kind of thing often works is:
>
>        acquire some lock
>                search for an object in some common data structure
>                bump the reference count on the found object
>        drop the lock
>
> So the lock protects the object from destruction until we get the
> reference count, and then the reference count protects it after we've
> dropped the lock.
>
> In this case we'll probably eventually transition to a spinlock
> protecting the client hash tables, and then do the above in the
> functions that look up clients, so that the object returned from those
> functions already comes with its own reference taken.


Got it - thanks

-->Andy

>
> --b.
>
>>
>> -->Andy
>>
>>>
>>>
>>> --b.
>>>
>>>>
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>> fs/nfsd/nfs4state.c |   14 ++++++++++----
>>>> 1 files changed, 10 insertions(+), 4 deletions(-)
>>>>
>>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>>> index a585a58..accad58 100644
>>>> --- a/fs/nfsd/nfs4state.c
>>>> +++ b/fs/nfsd/nfs4state.c
>>>> @@ -1355,6 +1355,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>>>     conf = find_confirmed_client(&cr_ses->clientid);
>>>>
>>>>     if (conf) {
>>>> +           atomic_inc(&conf->cl_count);
>>>>             slot = &conf->cl_slot;
>>>>             status = check_slot_seqid(cr_ses->seqid, slot);
>>>>             if (status == nfserr_replay_cache) {
>>>> @@ -1363,27 +1364,30 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>>>                     cstate->status = nfserr_replay_clientid_cache;
>>>>                     /* Return the cached reply status */
>>>>                     status = nfsd4_replay_create_session(resp, slot);
>>>> -                   goto out;
>>>> +                   goto out_put;
>>>>             } else if (cr_ses->seqid != conf->cl_slot.sl_seqid + 1) {
>>>>                     status = nfserr_seq_misordered;
>>>>                     dprintk("Sequence misordered!\n");
>>>>                     dprintk("Expected seqid= %d but got seqid= %d\n",
>>>>                             slot->sl_seqid, cr_ses->seqid);
>>>> -                   goto out;
>>>> +                   goto out_put;
>>>>             }
>>>>             conf->cl_slot.sl_seqid++;
>>>>     } else if (unconf) {
>>>> +           atomic_inc(&unconf->cl_count);
>>>>             slot = &unconf->cl_slot;
>>>>             status = check_slot_seqid(cr_ses->seqid, slot);
>>>>             if (status) {
>>>>                     /* an unconfirmed replay returns misordered */
>>>>                     status = nfserr_seq_misordered;
>>>> -                   goto out;
>>>> +                   conf = unconf; /* for put_nfs4_client */
>>>> +                   goto out_put;
>>>>             }
>>>>
>>>>             if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
>>>>                 (ip_addr != unconf->cl_addr)) {
>>>>                     status = nfserr_clid_inuse;
>>>> +                   conf = unconf; /* for put_nfs4_client */
>>>>                     goto out_cache;
>>>>             }
>>>>
>>>> @@ -1413,7 +1417,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
>>>>
>>>>     status = alloc_init_session(rqstp, conf, cr_ses);
>>>>     if (status)
>>>> -           goto out;
>>>> +           goto out_put;
>>>>
>>>>     memcpy(cr_ses->sessionid.data, conf->cl_sessionid.data,
>>>>            NFS4_MAX_SESSIONID_LEN);
>>>> @@ -1423,6 +1427,8 @@ out_cache:
>>>>     /* cache solo and embedded create sessions under the state lock */
>>>>     nfsd4_cache_create_session(cr_ses, slot, status);
>>>>
>>>> +out_put:
>>>> +   put_nfs4_client(conf);
>>>> out:
>>>>     nfs4_unlock_state();
>>>>     dprintk("%s returns %d\n", __func__, ntohl(status));
>>>> --
>>>> 1.5.4.3
>>>>
>>
> _______________________________________________
> pNFS mailing list
> pNFS@linux-nfs.org
> http://linux-nfs.org/cgi-bin/mailman/listinfo/pnfs
>
