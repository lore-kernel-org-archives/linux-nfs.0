Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:53233 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600AbaJMWYW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Oct 2014 18:24:22 -0400
Received: by mail-vc0-f179.google.com with SMTP id im17so6549534vcb.38
        for <linux-nfs@vger.kernel.org>; Mon, 13 Oct 2014 15:24:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGsopFNFjo=LBwYE9n6b7Emv73Rkw0H2wyq2vCjMUOftA@mail.gmail.com>
References: <CAN-5tyHwG=Cn2Q9KsHWadewjpTTy_K26ee+UnSvHvG4192p-Xw@mail.gmail.com>
	<CAHQdGtRuWdHBPfBzCTmDwsYXtpqNSwpGUdtoUqs3jWAd2unxEQ@mail.gmail.com>
	<CAN-5tyGUxgjpcb2=jnQQOD60ernNzf1YSnTG8B-NXUP5OidEFw@mail.gmail.com>
	<CAHQdGtQ=RBoO1u_7501-G2rbDEGim5Hh2G6zuWyyLVVy8QAQWw@mail.gmail.com>
	<CAHQdGtRo2uw5U1-w9O2U=4C8BwxCECAjjeC9SCdkyEP8FQ94Gw@mail.gmail.com>
	<CAN-5tyGsopFNFjo=LBwYE9n6b7Emv73Rkw0H2wyq2vCjMUOftA@mail.gmail.com>
Date: Mon, 13 Oct 2014 18:24:21 -0400
Message-ID: <CAHQdGtSQJLe60ja+-ChkHXOu8_UjmOpd4X7QHyhNOj1mPQGWPg@mail.gmail.com>
Subject: Re: how to properly handle failures during delegation recall process
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 13, 2014 at 6:13 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Mon, Oct 13, 2014 at 5:29 PM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Mon, Oct 13, 2014 at 5:12 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> On Mon, Oct 13, 2014 at 4:23 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>> On Mon, Oct 13, 2014 at 3:53 PM, Trond Myklebust
>>>> <trond.myklebust@primarydata.com> wrote:
>>>>> On Mon, Oct 13, 2014 at 2:51 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>> +               }
>>>>>> +       }
>>>>>>         return nfs4_handle_delegation_recall_error(server, state, stateid, err);
>>>>>>  }
>>>>>>
>>>>>> @@ -5957,6 +5973,10 @@ int nfs4_lock_delegation_recall(struct
>>>>>> file_lock *fl, struct nfs4_state *state,
>>>>>>         err = nfs4_set_lock_state(state, fl);
>>>>>>         if (err != 0)
>>>>>>                 return err;
>>>>>> +       if (test_bit(NFS_LOCK_LOST, &fl->fl_u.nfs4_fl.owner->ls_flags)) {
>>>>>> +               pr_warn_ratelimited("NFS: %s: Lock reclaim failed!\n",
>>>>>> __func__);
>>>>>> +               return -EIO;
>>>>>> +       }
>>>>>>         err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
>>>>>
>>>>> Note that there is a potential race here if the server is playing with
>>>>> NFS4ERR_DELEG_REVOKED or NFS4ERR_ADMIN_REVOKED. Since we do not
>>>>> present the delegation as part of the LOCK request, we have no way of
>>>>> knowing if the delegation is still in effect. I guess we can check the
>>>>> return value of DELEGRETURN, but if it returns NFS4ERR_DELEG_REVOKED
>>>>> or NFS4ERR_ADMIN_REVOKED, then we still do not know whether or not the
>>>>> LOCK is safe.
>>>>
>>>> I'm not following you. We send LOCK before we send DELEGRETURN? Also,
>>>> we normally send in LOCK the open_stateid returned by the open with
>>>> cur so do we know that delegation is still in effect.
>>>
>>> How so? The open stateid doesn't tell you that the delegation is still
>>> in effect. If the DELEGRETURN returns NFS4ERR_DELEG_REVOKED, how can
>>> you tell if the delegation was revoked before or after the LOCK
>>> request was handled?
>>
>> Actually, let me answer that myself. You can sort of figure things out
>> in NFSv4.1 if you look at the SEQ4_STATUS_RECALLABLE_STATE_REVOKED
>> flag. If it is set, you should probably distrust the lock stateid that
>> you just attempted to recover, since you now know that at least one
>> delegation was just revoked.
>>
>> In that case, we probably also have to do a TEST_STATEID+FREE_STATEID
>> on the delegation stateid.
>
> I think we are mis-communicating here by talking about different
> nuances. I agree with you that when an operation is sent there is no
> way of knowing if in the mean while the server has decided to revoke
> the delegation. However, this is not what I'm confused about regarding
> your comment. I'm noticing that in the flow of operations, we send (1)
> open with cur, then (2) lock, then (3) delegreturn. So I was confused
> about how can we check return of delegreturn, step 3, if we are in
> step 2.
>
> I think the LOCK is safe if the reply to the LOCK is successful.

It needs to be concurrent with the delegation as well, otherwise
general lock atomicity is broken.

> Let me just step back from this to note that your solution to "lost
> locks during delegation" is to recognize the open with cure failure
> and skip locking and delegreturn. I can work on a patch for that.
>
> Do you agree that the state recovery should not be initiated in case
> we get those errors?

State recovery _should_ be initiated so that we do reclaim opens (I
don't care about share lock atomicity on Linux). However
nfs_delegation_claim_locks() _should_not_ be called.

I'll give some more thought as to how we can ensure the missing lock atomicity.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
