Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35821 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933157AbdBPWOL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Feb 2017 17:14:11 -0500
Received: by mail-it0-f67.google.com with SMTP id 203so6472721ith.2
        for <linux-nfs@vger.kernel.org>; Thu, 16 Feb 2017 14:14:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <D28A97BA-F86E-40D3-A0E3-BB8479136ED9@primarydata.com>
References: <20161205004023.40957-1-trond.myklebust@primarydata.com>
 <CAN-5tyGN4AT70mrVKoW652hQmbDocG7_c2haDC=PKpixQsUDJg@mail.gmail.com>
 <1487191695.7993.2.camel@primarydata.com> <CAN-5tyGep3yHXNjMX9QKCS8E2w+HkVw_LoF=pOwgbgcgUNeDyQ@mail.gmail.com>
 <1487197395.7993.4.camel@primarydata.com> <CAN-5tyHHUoy5sVUHO=PXz3iRPD6eEP0t+L8VrWVpuvSd_YzhAA@mail.gmail.com>
 <CAN-5tyFZO4dKG93A71mO37VdHJymMt0f61oLkxMHvRDPEvSa2g@mail.gmail.com>
 <CAN-5tyGb6Gh=k0r1M4UmpM+6fB9nMzi3OGmB_trbSjbCdJjqrQ@mail.gmail.com> <D28A97BA-F86E-40D3-A0E3-BB8479136ED9@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 16 Feb 2017 17:14:10 -0500
Message-ID: <CAN-5tyHe-+PiOnx8U9u-3FPVVAYf9AbbcZUDM6BW+V6930tHtA@mail.gmail.com>
Subject: Re: [PATCH 1/2] NFSv4.1: Handle NFS4ERR_BADSESSION/NFS4ERR_DEADSESSION
 replies to OP_SEQUENCE
To: Trond Myklebust <trondmy@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 16, 2017 at 4:45 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Feb 16, 2017, at 11:12, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Thu, Feb 16, 2017 at 11:04 AM, Olga Kornievskaia <aglo@umich.edu> wro=
te:
>>> On Thu, Feb 16, 2017 at 9:16 AM, Olga Kornievskaia <aglo@umich.edu> wro=
te:
>>>> On Wed, Feb 15, 2017 at 5:23 PM, Trond Myklebust
>>>> <trondmy@primarydata.com> wrote:
>>>>> On Wed, 2017-02-15 at 16:56 -0500, Olga Kornievskaia wrote:
>>>>>> On Wed, Feb 15, 2017 at 3:48 PM, Trond Myklebust
>>>>>> <trondmy@primarydata.com> wrote:
>>>>>>> On Wed, 2017-02-15 at 15:16 -0500, Olga Kornievskaia wrote:
>>>>>>>> On Sun, Dec 4, 2016 at 7:40 PM, Trond Myklebust
>>>>>>>> <trond.myklebust@primarydata.com> wrote:
>>>>>>>>> In the case where SEQUENCE receives a NFS4ERR_BADSESSION or
>>>>>>>>> NFS4ERR_DEADSESSION error, we just want to report the session
>>>>>>>>> as
>>>>>>>>> needing
>>>>>>>>> recovery, and then we want to retry the operation.
>>>>>>>>>
>>>>>>>>> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com
>>>>>>>>>>
>>>>>>>>> ---
>>>>>>>>> fs/nfs/nfs4proc.c | 4 ++++
>>>>>>>>> 1 file changed, 4 insertions(+)
>>>>>>>>>
>>>>>>>>> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
>>>>>>>>> index f992281c9b29..4fd0e2b7b08e 100644
>>>>>>>>> --- a/fs/nfs/nfs4proc.c
>>>>>>>>> +++ b/fs/nfs/nfs4proc.c
>>>>>>>>> @@ -816,6 +816,10 @@ static int nfs41_sequence_process(struct
>>>>>>>>> rpc_task *task,
>>>>>>>>>        case -NFS4ERR_SEQ_FALSE_RETRY:
>>>>>>>>>                ++slot->seq_nr;
>>>>>>>>>                goto retry_nowait;
>>>>>>>>> +       case -NFS4ERR_DEADSESSION:
>>>>>>>>> +       case -NFS4ERR_BADSESSION:
>>>>>>>>> +               nfs4_schedule_session_recovery(session, res-
>>>>>>>>>> sr_status);
>>>>>>>>>
>>>>>>>>> +               goto retry_nowait;
>>>>>>>>>        default:
>>>>>>>>>                /* Just update the slot sequence no. */
>>>>>>>>>                slot->seq_done =3D 1;
>>>>>>>>> --
>>>>>>>>> 2.9.3
>>>>>>>>
>>>>>>>> Hi Trond,
>>>>>>>>
>>>>>>>> Can you explain the implications of retrying the operation
>>>>>>>> without
>>>>>>>> waiting for recovery to complete?
>>>>>>>>
>>>>>>>> This patch introduces regression in intra COPY failing if the
>>>>>>>> server
>>>>>>>> rebooted during that operation. What happens is that COPY is re-
>>>>>>>> sent
>>>>>>>> with the same stateid from the old open instead of the open that
>>>>>>>> was
>>>>>>>> done from the recovery (leading to BAD_STATEID error and
>>>>>>>> failure).
>>>>>>>>
>>>>>>>> I wonder if it's because COPY is written to just use
>>>>>>>> nfs4_call_sync()
>>>>>>>> instead of defining rpc_callback_ops to handle rpc_prepare()
>>>>>>>> where a
>>>>>>>> new stateid could be gotten? I have re-written the COPY to do
>>>>>>>> that
>>>>>>>> and
>>>>>>>> I no longer see that problem.
>>>>>>>>
>>>>>>>> If my suspicion is correct, it would help for the future to know
>>>>>>>> that
>>>>>>>> any operations that use stateid must have rpc callback ops
>>>>>>>> defined/used so that they avoid this problem. Perhaps as a
>>>>>>>> comment in
>>>>>>>> the code or maybe some other way?
>>>>>>>>
>>>>>>>> Thanks.
>>>>>>>>
>>>>>>>
>>>>>>> Yes, the way that rpc_call_sync() has been written, it assumes that
>>>>>>> the
>>>>>>> call is unaffected by reboot recovery, or that the resulting state
>>>>>>> errors will be handled by the caller. The patch you reference does
>>>>>>> not
>>>>>>> change that expectation.
>>>>>>
>>>>>> The "or" is confusing me. The current COPY code does call into
>>>>>> nfs4_handle_exception() and "should handle errors". Yet after this
>>>>>> patch, the code fails to in presence of a reboot. I don't see what
>>>>>> else can the current code should do in terms of handling errors to
>>>>>> fix
>>>>>> that problem.
>>>>>>
>>>>>> I'm almost ready to submit the patch that turns the existing code
>>>>>> into
>>>>>> async rpc but if this is not the right approach then I'd like to kno=
w
>>>>>> where I should be looking into instead.
>>>>>>
>>>>>> Thanks.
>>>>>>
>>>>>>>
>>>>>>> The same race can happen, for instance, if your call to
>>>>>>> rpc_call_sync()
>>>>>>> coincides with a reboot recovery that was started by another
>>>>>>> process.
>>>>>>>
>>>>>
>>>>>
>>>>> I don't understand. If it is handling the resulting NFS4ERR_BAD_STATE=
ID
>>>>> error correctly, then what is failing? As I said above, you can get t=
he
>>>>> NFS4ERR_BAD_STATEID from other instances of the same race.
>>>>
>>>> COPY (just like READ or WRITE) can not handle BAD_STATEID error
>>>> because it holds a lock and that lock is marked lost. COPY should have
>>>> never been sent with the old stated after the new open stateid and
>>>> lock stateid was gotten. But with this patch the behavior changed and
>>>> thus I was trying to understand what has changed.
>>>>
>>>> I think that previously BAD_SESSION error was not handled by the
>>>> SEQUENCE and was handled by each of the operations calling the general
>>>> nfs4_handle_exception() routine that actually waits on recovery to
>>>> complete before retrying the operation. Then the retry actually would
>>>> allow COPY to get the new stateid. However, with the new code SEQUENCE
>>>> handles the error and calls to retry the operation without the wait
>>>> which actually again gets the BAD_SESSION then recovery happens but
>>>> 2nd SEQUENCE again retries the operation without going all the out to
>>>> the operation so no new stateid is gotten.
>>>>
>>>
>>> I also would like to point out that not only does this patch
>>> introduces a regression with the COPY. It also introduces the
>>> BAD_SESSION loop where the SEQUENCE that gets this error just keeps
>>> getting resent over and over again. This happens to the heartbeat
>>> SEQUENCE when server reboots.
>>
>> I have written a test case for the SETATTR since it also uses a
>> stateid and calls nfs4_sync_call() and it also after the reboot will
>> send the operation with the old stateid. Thankfully, SETATTR doesn't
>> really care about the 'validity' of the stateid and will retry the
>> operation. It will produce no errors but I can't say the client is
>> working properly.
>
> That=E2=80=99s because SETATTR was designed correctly. Just like copy off=
load, it has to deal with the fact that it can race with a server reboot.

Let's agree to disagree that design is correct. Copy offload does
everything that current design asks it to do but there is still a
failure so let's figure out how to fix it.

> Olga, all your test is doing is showing that we hit the race more often. =
Fair enough, I=E2=80=99ll ask Anna to revert the patch. However reverting t=
he patch won=E2=80=99t prevent the server from returning NFS4ERR_BAD_STATEI=
D in any cases where the calls to nfs4_set_rw_stateid() happen before state=
 recovery. This is why we have the loop in nfs42_proc_copy().

I thought that if retry of the operation waits for the recovery to
complete then nfs4_set_rw_stateid() will choose the correct stateid,
is that not correct?

If that's not correct, then we somehow need to separate the case when
BAD_STATEID should indeed mark the locks lost vs this case where the
code erroneously used the bad stateid (oops) and it should really
ignore this error. This really doesn't sound very plausible to
accomplish.

>> So I'd save that the patch has introduced some significant change to
>> the philosophy that wasn't expected.
>
> No. The philosophy is the same. Both with or without this patch, an RPC c=
all that carries a stated MUST be prepared to handle NFS4ERR_BAD_STATEID.
>
> _________________________________
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
>
