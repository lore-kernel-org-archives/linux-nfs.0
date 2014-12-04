Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:61046 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215AbaLDS6S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2014 13:58:18 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so19160966igb.17
        for <linux-nfs@vger.kernel.org>; Thu, 04 Dec 2014 10:58:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSq7XSYMMnEFRrG5M2znFjzyhSdoKkkJvf6YjTRusVu_A@mail.gmail.com>
References: <CAN-5tyFpbM5GE2fAcx8uMG6MO2JC-R4ASN_jrnmYH8idie_H+w@mail.gmail.com>
	<CAHQdGtSR7HV1vzcAXQRsL1U-FeQuBv7-qNeNVEr35+9+0zcpCw@mail.gmail.com>
	<CAN-5tyFur64r5M7QcrAnOb37du6yi6bjFM0kwdu0NvotZSw3uw@mail.gmail.com>
	<CAHQdGtRMDzvDE-DyH0+0hqdT0czc+XPNz9uOXARr6QzKhkjzBQ@mail.gmail.com>
	<CAN-5tyF5B_vTGTrrO-1dEpepXUMVSewsn8wPkOjnZ18d4xMQ+w@mail.gmail.com>
	<CAHQdGtQmeiNnd-+EMY1_f3a=9-5KV66reTXbQyi4vp89m=sxgA@mail.gmail.com>
	<CAN-5tyH8wAZioGZeVGpQCfiiBs4JipfRwsHAgdyVfXGkMdEBGg@mail.gmail.com>
	<CAN-5tyG78XkxyxtVdE=qPx+cpPCTLbvvdWW-YfpKMx_vZkxu3w@mail.gmail.com>
	<CAHQdGtSq7XSYMMnEFRrG5M2znFjzyhSdoKkkJvf6YjTRusVu_A@mail.gmail.com>
Date: Thu, 4 Dec 2014 13:58:17 -0500
Message-ID: <CAN-5tyFDhr+6jGi67gq3LLqu-QAtJsN-MG3oHHCSyNqGONuT6A@mail.gmail.com>
Subject: Re: not picking a delegation stateid for IO when delegation stateid
 is being returned
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 4, 2014 at 1:23 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Thu, Dec 4, 2014 at 12:36 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> On Wed, Dec 3, 2014 at 6:50 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> On Wed, Dec 3, 2014 at 6:34 PM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>>
>>>> On Dec 3, 2014 6:21 PM, "Olga Kornievskaia" <aglo@umich.edu> wrote:
>>>>>
>>>>> On Wed, Dec 3, 2014 at 6:13 PM, Trond Myklebust
>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>> > On Wed, Dec 3, 2014 at 5:59 PM, Olga Kornievskaia <aglo@umich.edu>
>>>>> > wrote:
>>>>> >> On Wed, Dec 3, 2014 at 3:59 PM, Trond Myklebust
>>>>> >> <trond.myklebust@primarydata.com> wrote:
>>>>> >>> Hi Olga,
>>>>> >>>
>>>>> >>> On Wed, Dec 3, 2014 at 2:54 PM, Olga Kornievskaia <aglo@umich.edu>
>>>>> >>> wrote:
>>>>> >>>> Hi folks,
>>>>> >>>>
>>>>> >>>> I would like an opinion about changing code in such as way that we
>>>>> >>>> don't select a delegation stateid for an IO operation when this
>>>>> >>>> particular delegation is being returned.
>>>>> >>>>
>>>>> >>>> The reason it's some what problematic is that we send out a
>>>>> >>>> DELEG_RETURN and then we don't remove the stateid until we receive a
>>>>> >>>> reply. In the mean while, an IO operation can be happening and in
>>>>> >>>> nfs4_select_rw_stateid() it sees a delegation stateid and uses it.
>>>>> >>>> Well, at the server, it finishes processing DELEG_RETURN before
>>>>> >>>> getting an IO op and by that time the server is finished with the
>>>>> >>>> stateid and can error an IO operation with BAD_STATEID.
>>>>> >>>>
>>>>> >>>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>>>>> >>>> index 7f3f606..4f6f6c9 100644
>>>>> >>>> --- a/fs/nfs/delegation.c
>>>>> >>>> +++ b/fs/nfs/delegation.c
>>>>> >>>> @@ -854,7 +854,8 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid
>>>>> >>>> *dst, struct inode *in
>>>>> >>>>         flags &= FMODE_READ|FMODE_WRITE;
>>>>> >>>>         rcu_read_lock();
>>>>> >>>>         delegation = rcu_dereference(nfsi->delegation);
>>>>> >>>> -       ret = (delegation != NULL && (delegation->type & flags) ==
>>>>> >>>> flags);
>>>>> >>>> +       ret = (delegation != NULL && (delegation->type & flags) ==
>>>>> >>>> flags &&
>>>>> >>>> +               !test_bit(NFS_DELEGATION_RETURNING,
>>>>> >>>> &delegation->flags));
>>>>> >>>>         if (ret) {
>>>>> >>>>                 nfs4_stateid_copy(dst, &delegation->stateid);
>>>>> >>>>                 nfs_mark_delegation_referenced(delegation);
>>>>> >>>
>>>>> >>> The above cannot eliminate the possibility that we won't use a
>>>>> >>> delegation while it is being returned. It will at best just reduce the
>>>>> >>> window of opportunity.
>>>>> >>>
>>>>> >>
>>>>> >> You are right this are still problems. Actually, we might set the bit
>>>>> >> but not yet get the open stateid from the open with deleg_cur and
>>>>> >> that's not good. It would be good to know we got the open stateid and
>>>>> >> then pick that.
>>>>> >>
>>>>> >>> So, why is this being considered to be a problem in the first place?
>>>>> >>> Are you seeing a measurable performance impact on a real life workload
>>>>> >>> (as opposed to some 1-in-a-billion occurrence from a QA test :-))?
>>>>> >>
>>>>> >> Unfortunately, this problem is quite common and I hit it all the time
>>>>> >> on my setup. This leads to client seizing IO on that file and
>>>>> >> returning EIO. It's an unrecoverable error. I'm trying to figure out
>>>>> >> how to eliminate getting to that state.
>>>>> >>
>>>>> >
>>>>> > It definitely isn't intended to be an irrecoverable error. The client
>>>>> > is supposed to just replay the write after updating the stateid.
>>>>>
>>>>> open(deleg_cur) call / reply
>>>>> lock() call/reply
>>>>> deleg_return() call
>>>>> write(with deluge_stateid) call gets BAD_STATEID
>>>>> state recovery code marks lock state lost -> EIO.
>>>>
>>>> Why is it marking the lock as lost? If the recovery succeeded, it should
>>>> notice that the stateid has changed and instead retry.
>>>
>>> I'll get you a better explanation tomorrow besides saying "that's what
>>> I see when I run the code".
>>
>> nfs4_async_handle_error() initiates state recovery
>> nfs4_reclaim_open_state() eventually calls  nfs4_reclaim_locks() which
>> marks the lock LOST. state is delegated so the kernel logs "lock
>> reclaim failed".
>> write retries and in nfs4_copy_ lock_stateid() the lock is marked LOST
>> and the nfs4_select_rw_stateid() fails with EIO.
>>
>>>
>>>> What kernel is this?
>>>
>>> This is upstream.
>
> So why isn't nfs4_write_stateid_changed() catching the change before
> we even get to nfs4_async_handle_error()? That's where this race is
> supposed to get resolved.

Probably because nfs4_stateid_is_current() returns true because
nfs4_set_rw_stateid() calls the nfs4_select_rw_stateid() and finds the
lock lost?

>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
