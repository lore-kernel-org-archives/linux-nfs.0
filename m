Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f41.google.com ([209.85.218.41]:35647 "EHLO
	mail-oi0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175AbbIQNes convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Sep 2015 09:34:48 -0400
Received: by oiww128 with SMTP id w128so9381646oiw.2
        for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2015 06:34:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHKSPm6-BERVMExhrpMbg2cipD=WifcZyybvFDmtpQaWQ@mail.gmail.com>
References: <CAN-5tyF_cHmiPvEqv8N8S_J-TBymOZV+-A0Vh+GCnP3czFB-wg@mail.gmail.com>
	<CAHQdGtTeOx3SZSmC4JEAA7jfQRnB=tDjMamW5-amyT3mCq4zOw@mail.gmail.com>
	<CAN-5tyFM2WVdGUSEAp27GXe_52DrJWGGQrxuniJqOqDf-6wiUg@mail.gmail.com>
	<CAHQdGtTkiTnQXB6Jf0GBZT1xQjc64hz3b+oUt-0ZOyQiSgZ8cQ@mail.gmail.com>
	<CAN-5tyHKSPm6-BERVMExhrpMbg2cipD=WifcZyybvFDmtpQaWQ@mail.gmail.com>
Date: Thu, 17 Sep 2015 09:34:47 -0400
Message-ID: <CAHQdGtSO3skVYq+0LUBCbDqorOESJ2mjqC=FQ+7Y98P5mQpEAw@mail.gmail.com>
Subject: Re: Failing to send a CLOSE if file is opened WRONLY and server
 reboots on a 4.x mount
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 15, 2015 at 12:52 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Tue, Sep 15, 2015 at 11:49 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> On Tue, Sep 15, 2015 at 10:27 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>> On Tue, Sep 15, 2015 at 9:39 AM, Trond Myklebust
>>> <trond.myklebust@primarydata.com> wrote:
>>>> On Mon, Sep 14, 2015 at 7:54 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>> A test case is as the description says:
>>>>> open(foobar, O_WRONLY);
>>>>> sleep()  --> reboot the server
>>>>> close(foobar)
>>>>>
>>>>> The bug is because in nfs4state.c in nfs4_reclaim_open_state() a few
>>>>> line before going to restart, there is
>>>>> clear_bit(NFS4CLNT_RECLAIM_NOGRACE, &state->flags).
>>>>>
>>>>> NFS4CLNT_RECLAIM_NOGRACE is a flag for the client states not open
>>>>> owner states. Value of NFS4CLNT_RECLAIM_NOGRACE is 4 which is the
>>>>> value of NFS_O_WRONLY_STATE in nfs4_state->flags. So clearing it wipes
>>>>> out state and when we go to close it, “call_close” doesn’t get set as
>>>>> state flag is not set and CLOSE doesn’t go on the wire.
>>>>>
>>>>> That line was introduced to fix an infinite loop for OPEN recovery
>>>>> upon receiving a BAD_STATEID error: commit e8d975e73. I have tested
>>>>> injecting BAD_STATEID error using the patch below and the code
>>>>> recovers without problems. However, I'm not sure the clearing of the
>>>>> bit is needed any more. I have tested for infinite loop by reverting
>>>>> the patch and didn't hit the infinite loop.
>>>>>
>>>>> diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
>>>>> index da73bc4..5db3246 100644
>>>>> --- a/fs/nfs/nfs4state.c
>>>>> +++ b/fs/nfs/nfs4state.c
>>>>> @@ -1481,7 +1481,7 @@ restart:
>>>>>                                         spin_unlock(&state->state_lock);
>>>>>                                 }
>>>>>                                 nfs4_put_open_state(state);
>>>>> -                               clear_bit(NFS4CLNT_RECLAIM_NOGRACE,
>>>>> +                               clear_bit(NFS_STATE_RECLAIM_NOGRACE,
>>>>>                                         &state->flags);
>>>>>                                 spin_lock(&sp->so_lock);
>>>>>                                 goto restart;
>>>>
>>>> That's an obvious typo. Thanks for spotting it!
>>>>
>>>> As for whether or not the bit clear is needed at all, I think it is
>>>> for NFSv4 on older kernels. On newer kernels, we do have the NFSv4
>>>> state recovery drain the slot table (just like we've always done for
>>>> NFSv4.1) and so I agree that those kernels probably won't be
>>>> afflicted.
>>>>
>>>
>>> Thanks Trond. Do you need me to resubmit it without the last paragraph
>>> or is the patch ok as is?
>>>
>>
>> I can easily remove that paragraph when applying the patch, if you
>> agree that it is superfluous.
>
> Thanks. Works for me.
>

May I also add a signed-off-by line from you? I can't really apply
this (or any other patches) without it.

Cheers
  Trond
