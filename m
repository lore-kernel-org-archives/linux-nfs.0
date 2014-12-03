Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:55012 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbaLCXV2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Dec 2014 18:21:28 -0500
Received: by mail-ig0-f182.google.com with SMTP id hn15so13698337igb.9
        for <linux-nfs@vger.kernel.org>; Wed, 03 Dec 2014 15:21:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtRMDzvDE-DyH0+0hqdT0czc+XPNz9uOXARr6QzKhkjzBQ@mail.gmail.com>
References: <CAN-5tyFpbM5GE2fAcx8uMG6MO2JC-R4ASN_jrnmYH8idie_H+w@mail.gmail.com>
	<CAHQdGtSR7HV1vzcAXQRsL1U-FeQuBv7-qNeNVEr35+9+0zcpCw@mail.gmail.com>
	<CAN-5tyFur64r5M7QcrAnOb37du6yi6bjFM0kwdu0NvotZSw3uw@mail.gmail.com>
	<CAHQdGtRMDzvDE-DyH0+0hqdT0czc+XPNz9uOXARr6QzKhkjzBQ@mail.gmail.com>
Date: Wed, 3 Dec 2014 18:21:27 -0500
Message-ID: <CAN-5tyF5B_vTGTrrO-1dEpepXUMVSewsn8wPkOjnZ18d4xMQ+w@mail.gmail.com>
Subject: Re: not picking a delegation stateid for IO when delegation stateid
 is being returned
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 3, 2014 at 6:13 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Wed, Dec 3, 2014 at 5:59 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> On Wed, Dec 3, 2014 at 3:59 PM, Trond Myklebust
>> <trond.myklebust@primarydata.com> wrote:
>>> Hi Olga,
>>>
>>> On Wed, Dec 3, 2014 at 2:54 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>> Hi folks,
>>>>
>>>> I would like an opinion about changing code in such as way that we
>>>> don't select a delegation stateid for an IO operation when this
>>>> particular delegation is being returned.
>>>>
>>>> The reason it's some what problematic is that we send out a
>>>> DELEG_RETURN and then we don't remove the stateid until we receive a
>>>> reply. In the mean while, an IO operation can be happening and in
>>>> nfs4_select_rw_stateid() it sees a delegation stateid and uses it.
>>>> Well, at the server, it finishes processing DELEG_RETURN before
>>>> getting an IO op and by that time the server is finished with the
>>>> stateid and can error an IO operation with BAD_STATEID.
>>>>
>>>> diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
>>>> index 7f3f606..4f6f6c9 100644
>>>> --- a/fs/nfs/delegation.c
>>>> +++ b/fs/nfs/delegation.c
>>>> @@ -854,7 +854,8 @@ bool nfs4_copy_delegation_stateid(nfs4_stateid
>>>> *dst, struct inode *in
>>>>         flags &= FMODE_READ|FMODE_WRITE;
>>>>         rcu_read_lock();
>>>>         delegation = rcu_dereference(nfsi->delegation);
>>>> -       ret = (delegation != NULL && (delegation->type & flags) == flags);
>>>> +       ret = (delegation != NULL && (delegation->type & flags) == flags &&
>>>> +               !test_bit(NFS_DELEGATION_RETURNING, &delegation->flags));
>>>>         if (ret) {
>>>>                 nfs4_stateid_copy(dst, &delegation->stateid);
>>>>                 nfs_mark_delegation_referenced(delegation);
>>>
>>> The above cannot eliminate the possibility that we won't use a
>>> delegation while it is being returned. It will at best just reduce the
>>> window of opportunity.
>>>
>>
>> You are right this are still problems. Actually, we might set the bit
>> but not yet get the open stateid from the open with deleg_cur and
>> that's not good. It would be good to know we got the open stateid and
>> then pick that.
>>
>>> So, why is this being considered to be a problem in the first place?
>>> Are you seeing a measurable performance impact on a real life workload
>>> (as opposed to some 1-in-a-billion occurrence from a QA test :-))?
>>
>> Unfortunately, this problem is quite common and I hit it all the time
>> on my setup. This leads to client seizing IO on that file and
>> returning EIO. It's an unrecoverable error. I'm trying to figure out
>> how to eliminate getting to that state.
>>
>
> It definitely isn't intended to be an irrecoverable error. The client
> is supposed to just replay the write after updating the stateid.

open(deleg_cur) call / reply
lock() call/reply
deleg_return() call
write(with deluge_stateid) call gets BAD_STATEID
state recovery code marks lock state lost -> EIO.

:-/

>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
