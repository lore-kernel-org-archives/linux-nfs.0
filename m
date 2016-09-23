Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:37668 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761003AbcIWUjA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 16:39:00 -0400
Received: by mail-it0-f49.google.com with SMTP id 186so26686618itf.0
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2016 13:39:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <C81A4BCC-76A8-4732-AAC1-93EF379B3302@primarydata.com>
References: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
 <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com> <CAN-5tyF3HrY9+xWO7HDnN_dv13vS9nqcp0vZpA29T=i3cJMSZg@mail.gmail.com>
 <AE31C3DC-40B8-4BBE-A5A1-A62CB656268A@primarydata.com> <CAN-5tyHgJ9K7=RChVt=sLHQbjTCRj8MhEmMipreMKWzef4Wscw@mail.gmail.com>
 <B8C98E5E-F9F5-4468-8E52-A3A4A550C1E3@primarydata.com> <CAN-5tyGC1MAq54yqQJffrNZoiaUppojmfgsqfQYrNwzhyFhoHg@mail.gmail.com>
 <F5E207D8-B71F-45BB-8114-63FF0F43136B@primarydata.com> <CAN-5tyFKk4VEdEb+P7qxGYwc6nnFvjyzCX304Jb4MAGzaJWKXA@mail.gmail.com>
 <9343A1DB-5895-41F4-8A37-504AA710D696@primarydata.com> <CAN-5tyEcv_BF60jJtAFRv3q3u3Yrqzvdhe=XWkQ2z3zKHc5C7A@mail.gmail.com>
 <CAN-5tyEoMw79hMsihpuKG=auLzir82DPqUj0fA8EycnUfPSmnw@mail.gmail.com> <C81A4BCC-76A8-4732-AAC1-93EF379B3302@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Sep 2016 16:38:58 -0400
Message-ID: <CAN-5tyFcE9kgiV0atOQyDV5eqKupLfoG9ACYba=bsXmYzmXyLQ@mail.gmail.com>
Subject: Re: reuse of slot and seq# when RPC was interrupted
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 23, 2016 at 4:34 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Sep 23, 2016, at 16:25, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Fri, Sep 23, 2016 at 4:07 PM, Olga Kornievskaia <aglo@umich.edu> wrot=
e:
>>> On Fri, Sep 23, 2016 at 3:57 PM, Trond Myklebust
>>> <trondmy@primarydata.com> wrote:
>>>>
>>>>> On Sep 23, 2016, at 15:27, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>
>>>>> On Fri, Sep 23, 2016 at 3:07 PM, Trond Myklebust
>>>>> <trondmy@primarydata.com> wrote:
>>>>>>
>>>>>>> On Sep 23, 2016, at 14:41, Olga Kornievskaia <aglo@umich.edu> wrote=
:
>>>>>>>
>>>>>>> On Fri, Sep 23, 2016 at 2:34 PM, Trond Myklebust
>>>>>>> <trondmy@primarydata.com> wrote:
>>>>>>>>
>>>>>>>>> On Sep 23, 2016, at 14:25, Olga Kornievskaia <aglo@umich.edu> wro=
te:
>>>>>>>>>
>>>>>>>>> On Fri, Sep 23, 2016 at 2:08 PM, Trond Myklebust
>>>>>>>>> <trondmy@primarydata.com> wrote:
>>>>>>>>>>
>>>>>>>>>>> On Sep 23, 2016, at 13:59, Olga Kornievskaia <aglo@umich.edu> w=
rote:
>>>>>>>>>>>
>>>>>>>>>>> On Fri, Sep 23, 2016 at 1:45 PM, Trond Myklebust
>>>>>>>>>>> <trondmy@primarydata.com> wrote:
>>>>>>>>>>>>
>>>>>>>>>>>>> On Sep 23, 2016, at 13:40, Olga Kornievskaia <aglo@umich.edu>=
 wrote:
>>>>>>>>>>>>>
>>>>>>>>>>>>> If we instead bump the sequence number in the case of interru=
pted and do:
>>>>>>>>>>>>
>>>>>>>>>>>> You have no guarantees that the server has seen and processed =
the operation.
>>>>>>>>>>>
>>>>>>>>>>> That is correct, i have tested the patch and made server never =
to
>>>>>>>>>>> receive the operation and client have an interrupted slot. On t=
he next
>>>>>>>>>>> operation the server will complain back with SEQ_MISORDERED. Cl=
ient
>>>>>>>>>>> can recover from this operation. Client can not recover from "R=
emote
>>>>>>>>>>> EIO=E2=80=9D.
>>>>>>>>>>>
>>>>>>>>>>
>>>>>>>>>> Why not?
>>>>>>>>>
>>>>>>>>> When XDR layer returns EREMOTEIO it's not handled by the NFS erro=
r
>>>>>>>>> recovery (are you suggesting we should?)  and returns that to the
>>>>>>>>> application.
>>>>>>>>>
>>>>>>>>
>>>>>>>> I=E2=80=99m saying that if we get a SEQ_MISORDERED due to a previo=
us interrupt on that slot, then we should ignore the error in task->tk_stat=
us, and just retry after bumping the slot seqid.
>>>>>>>>
>>>>>>>
>>>>>>> I'm confused where your objection lies. Are you ok with bumping the
>>>>>>> sequence # when task->tk_status =3D 1 and saying that we should sti=
ll
>>>>>>> keep the code that I deleted in the 2nd chunk of the patch that bum=
ped
>>>>>>> the seqid on getting SEQ_MISORDERED due to a previously interrupted
>>>>>>> slot?
>>>>>>> Wouldn't that create a difference of 2 slots for the server that ha=
s
>>>>>>> received the original request?
>>>>>>>
>>>>>>
>>>>>> I=E2=80=99m saying I=E2=80=99d prefer to keep the current code, but =
fix the retry that is apparently broken. If we=E2=80=99re not ignoring the =
task->tk_error when we decide to retry, then that=E2=80=99s a bug in my opi=
nion.
>>>>>
>>>>> I'm not understand what you are suggestion. I do better with example
>>>>> so allow me:
>>>>>
>>>>> REMOVE used slot 0 seq=3D00000036 received ctrl-c
>>>>> nfs41_sequence_done() gets called task->tk_status =3D 1:
>>>>> slot->interrupted is set to 1. slot is freed.
>>>>>
>>>>> next operation comes in, in my case it's ACCESS. initialization of th=
e
>>>>> sequence uses slot 0 seq=3D00000036
>>>>> server replies with REMOVE
>>>>>
>>>>> client code xdr in decode_op_hrs() returns EREMOTEIO. decode_access()
>>>>> returns EREMOTEIO. handle error just returns that error.
>>>>>
>>>>> where do we retry?
>>>>>
>>>>
>>>> The retry should be happening when we exit from nfs41_sequence_done() =
by restarting the RPC.
>>>
>>> Are you suggestion that REMOVE is retried? Ok I can see that (though
>>> I'm not sure why a killed task suppose to be retried. Wasn't it killed
>>> for a reason?). But if you are saying ACCESS should be retried then I
>>> don't see how it can fit into the code flow.
>>
>> I'm still hung up on the fact your suggestion of "retry". There is no
>> retry. You wrote "if we get a SEQ_MISORDERED" we never get
>> "SEQ_MISORDERED".
>>
>> I can see if you want to add to error_handling that we check if error
>> is EREMOTEIO and check that slot->interrupted is set, then we try?
>>
>
> Yes, that=E2=80=99s what I=E2=80=99d hope to see.

Ok I understand now and would try that.
