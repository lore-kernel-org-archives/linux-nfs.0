Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:33901 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034196AbcIWUZE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 16:25:04 -0400
Received: by mail-io0-f181.google.com with SMTP id e66so40114786iod.1
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2016 13:25:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyEcv_BF60jJtAFRv3q3u3Yrqzvdhe=XWkQ2z3zKHc5C7A@mail.gmail.com>
References: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
 <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com> <CAN-5tyF3HrY9+xWO7HDnN_dv13vS9nqcp0vZpA29T=i3cJMSZg@mail.gmail.com>
 <AE31C3DC-40B8-4BBE-A5A1-A62CB656268A@primarydata.com> <CAN-5tyHgJ9K7=RChVt=sLHQbjTCRj8MhEmMipreMKWzef4Wscw@mail.gmail.com>
 <B8C98E5E-F9F5-4468-8E52-A3A4A550C1E3@primarydata.com> <CAN-5tyGC1MAq54yqQJffrNZoiaUppojmfgsqfQYrNwzhyFhoHg@mail.gmail.com>
 <F5E207D8-B71F-45BB-8114-63FF0F43136B@primarydata.com> <CAN-5tyFKk4VEdEb+P7qxGYwc6nnFvjyzCX304Jb4MAGzaJWKXA@mail.gmail.com>
 <9343A1DB-5895-41F4-8A37-504AA710D696@primarydata.com> <CAN-5tyEcv_BF60jJtAFRv3q3u3Yrqzvdhe=XWkQ2z3zKHc5C7A@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Sep 2016 16:25:02 -0400
Message-ID: <CAN-5tyEoMw79hMsihpuKG=auLzir82DPqUj0fA8EycnUfPSmnw@mail.gmail.com>
Subject: Re: reuse of slot and seq# when RPC was interrupted
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 23, 2016 at 4:07 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Fri, Sep 23, 2016 at 3:57 PM, Trond Myklebust
> <trondmy@primarydata.com> wrote:
>>
>>> On Sep 23, 2016, at 15:27, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>
>>> On Fri, Sep 23, 2016 at 3:07 PM, Trond Myklebust
>>> <trondmy@primarydata.com> wrote:
>>>>
>>>>> On Sep 23, 2016, at 14:41, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>
>>>>> On Fri, Sep 23, 2016 at 2:34 PM, Trond Myklebust
>>>>> <trondmy@primarydata.com> wrote:
>>>>>>
>>>>>>> On Sep 23, 2016, at 14:25, Olga Kornievskaia <aglo@umich.edu> wrote=
:
>>>>>>>
>>>>>>> On Fri, Sep 23, 2016 at 2:08 PM, Trond Myklebust
>>>>>>> <trondmy@primarydata.com> wrote:
>>>>>>>>
>>>>>>>>> On Sep 23, 2016, at 13:59, Olga Kornievskaia <aglo@umich.edu> wro=
te:
>>>>>>>>>
>>>>>>>>> On Fri, Sep 23, 2016 at 1:45 PM, Trond Myklebust
>>>>>>>>> <trondmy@primarydata.com> wrote:
>>>>>>>>>>
>>>>>>>>>>> On Sep 23, 2016, at 13:40, Olga Kornievskaia <aglo@umich.edu> w=
rote:
>>>>>>>>>>>
>>>>>>>>>>> If we instead bump the sequence number in the case of interrupt=
ed and do:
>>>>>>>>>>
>>>>>>>>>> You have no guarantees that the server has seen and processed th=
e operation.
>>>>>>>>>
>>>>>>>>> That is correct, i have tested the patch and made server never to
>>>>>>>>> receive the operation and client have an interrupted slot. On the=
 next
>>>>>>>>> operation the server will complain back with SEQ_MISORDERED. Clie=
nt
>>>>>>>>> can recover from this operation. Client can not recover from "Rem=
ote
>>>>>>>>> EIO=E2=80=9D.
>>>>>>>>>
>>>>>>>>
>>>>>>>> Why not?
>>>>>>>
>>>>>>> When XDR layer returns EREMOTEIO it's not handled by the NFS error
>>>>>>> recovery (are you suggesting we should?)  and returns that to the
>>>>>>> application.
>>>>>>>
>>>>>>
>>>>>> I=E2=80=99m saying that if we get a SEQ_MISORDERED due to a previous=
 interrupt on that slot, then we should ignore the error in task->tk_status=
, and just retry after bumping the slot seqid.
>>>>>>
>>>>>
>>>>> I'm confused where your objection lies. Are you ok with bumping the
>>>>> sequence # when task->tk_status =3D 1 and saying that we should still
>>>>> keep the code that I deleted in the 2nd chunk of the patch that bumpe=
d
>>>>> the seqid on getting SEQ_MISORDERED due to a previously interrupted
>>>>> slot?
>>>>> Wouldn't that create a difference of 2 slots for the server that has
>>>>> received the original request?
>>>>>
>>>>
>>>> I=E2=80=99m saying I=E2=80=99d prefer to keep the current code, but fi=
x the retry that is apparently broken. If we=E2=80=99re not ignoring the ta=
sk->tk_error when we decide to retry, then that=E2=80=99s a bug in my opini=
on.
>>>
>>> I'm not understand what you are suggestion. I do better with example
>>> so allow me:
>>>
>>> REMOVE used slot 0 seq=3D00000036 received ctrl-c
>>> nfs41_sequence_done() gets called task->tk_status =3D 1:
>>> slot->interrupted is set to 1. slot is freed.
>>>
>>> next operation comes in, in my case it's ACCESS. initialization of the
>>> sequence uses slot 0 seq=3D00000036
>>> server replies with REMOVE
>>>
>>> client code xdr in decode_op_hrs() returns EREMOTEIO. decode_access()
>>> returns EREMOTEIO. handle error just returns that error.
>>>
>>> where do we retry?
>>>
>>
>> The retry should be happening when we exit from nfs41_sequence_done() by=
 restarting the RPC.
>
> Are you suggestion that REMOVE is retried? Ok I can see that (though
> I'm not sure why a killed task suppose to be retried. Wasn't it killed
> for a reason?). But if you are saying ACCESS should be retried then I
> don't see how it can fit into the code flow.

I'm still hung up on the fact your suggestion of "retry". There is no
retry. You wrote "if we get a SEQ_MISORDERED" we never get
"SEQ_MISORDERED".

I can see if you want to add to error_handling that we check if error
is EREMOTEIO and check that slot->interrupted is set, then we try?
