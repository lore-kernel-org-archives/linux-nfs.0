Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f47.google.com ([74.125.82.47]:54351 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755875Ab3LTCHM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Dec 2013 21:07:12 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so1857921wgh.2
        for <linux-nfs@vger.kernel.org>; Thu, 19 Dec 2013 18:07:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <52B0A982.6020001@primarydata.com>
References: <52ADCFC2.7060504@gmail.com> <1387122710-23603-1-git-send-email-bhalevy@primarydata.com>
 <CA+a=Yy6PeAZ_3Sbb4aHVMHTEOevkGzMmevTbKqxZ8K0dVpqFRg@mail.gmail.com> <52B0A982.6020001@primarydata.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Fri, 20 Dec 2013 10:06:50 +0800
Message-ID: <CA+a=Yy7TtEngoYn8ir6SfACmqCvuaRffzVFnspfwSi0fqAENNA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] nfsd4: break from inner lookup loop in
 nfsd4_release_lockowner on first match
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linuxnfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 18, 2013 at 3:44 AM, Benny Halevy <bhalevy@primarydata.com> wrote:
>
>
> On 12/16/2013 05:43 PM, Peng Tao wrote:
>> Hi Benny,
>>
>> On Sun, Dec 15, 2013 at 11:51 PM, Benny Halevy <bhalevy@primarydata.com> wrote:
>>> Otherwise the lockowner may by added to "matches" more than once.
>>>
>>> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
>>> ---
>>>  fs/nfsd/nfs4state.c | 17 +++++++++++------
>>>  1 file changed, 11 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
>>> index 0874998..b04f765 100644
>>> --- a/fs/nfsd/nfs4state.c
>>> +++ b/fs/nfsd/nfs4state.c
>>> @@ -4192,6 +4192,7 @@ alloc_init_lock_stateowner(unsigned int strhashval, struct nfs4_client *clp, str
>>>         /* It is the openowner seqid that will be incremented in encode in the
>>>          * case of new lockowners; so increment the lock seqid manually: */
>>>         lo->lo_owner.so_seqid = lock->lk_new_lock_seqid + 1;
>>> +       INIT_LIST_HEAD(&lo->lo_list);
>>>         hash_lockowner(lo, strhashval, clp, open_stp);
>>>         return lo;
>>>  }
>>> @@ -4646,7 +4647,6 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>>>         if (status)
>>>                 goto out;
>>>
>>> -       status = nfserr_locks_held;
>>>         INIT_LIST_HEAD(&matches);
>>>
>>>         list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
>>> @@ -4654,25 +4654,30 @@ nfsd4_release_lockowner(struct svc_rqst *rqstp,
>>>                         continue;
>>>                 if (!same_owner_str(sop, owner, clid))
>>>                         continue;
>>> +               lo = lockowner(sop);
>>>                 list_for_each_entry(stp, &sop->so_stateids,
>>>                                 st_perstateowner) {
>>> -                       lo = lockowner(sop);
>>> -                       if (check_for_locks(stp->st_file, lo))
>>> -                               goto out;
>>> +                       if (check_for_locks(stp->st_file, lo)) {
>>> +                               status = nfserr_locks_held;
>>> +                               goto locks_held;
>>> +                       }
>>>                         list_add(&lo->lo_list, &matches);
>>> +                       break;
>> If so_stateids is empty, lockowner is skipped. It was skipped before
>> the patch as well but I guess that need to be fixed, right?
>
> I'm not sure that's a valid state at all.
OK. I see the comments in lookup_or_create_lock_state() that says:

/* XXX: a lockowner always has exactly one stateid: */

And lookup_or_create_lock_state() does implement that way. So
so_stateid always has exactly one member for lockowner. But then the
original code (before the patch) is working properly, right? The
list_for_each_entry can be replaced with list_first_entry and the
added break doesn't seem necessary. Or is the situation somehow
obsolete?

Thanks,
Tao
