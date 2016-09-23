Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:36007 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965388AbcIWSli (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Sep 2016 14:41:38 -0400
Received: by mail-io0-f177.google.com with SMTP id m79so127404265ioo.3
        for <linux-nfs@vger.kernel.org>; Fri, 23 Sep 2016 11:41:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <B8C98E5E-F9F5-4468-8E52-A3A4A550C1E3@primarydata.com>
References: <CAN-5tyFQ2PiSHp41mOMHa=DSJ8SmXBo=Nk=v-k1hASPKRbbhzQ@mail.gmail.com>
 <AE6F91D9-2D4E-4AA0-A1F3-EB511E53F990@primarydata.com> <CAN-5tyF3HrY9+xWO7HDnN_dv13vS9nqcp0vZpA29T=i3cJMSZg@mail.gmail.com>
 <AE31C3DC-40B8-4BBE-A5A1-A62CB656268A@primarydata.com> <CAN-5tyHgJ9K7=RChVt=sLHQbjTCRj8MhEmMipreMKWzef4Wscw@mail.gmail.com>
 <B8C98E5E-F9F5-4468-8E52-A3A4A550C1E3@primarydata.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 23 Sep 2016 14:41:37 -0400
Message-ID: <CAN-5tyGC1MAq54yqQJffrNZoiaUppojmfgsqfQYrNwzhyFhoHg@mail.gmail.com>
Subject: Re: reuse of slot and seq# when RPC was interrupted
To: Trond Myklebust <trondmy@primarydata.com>
Cc: List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 23, 2016 at 2:34 PM, Trond Myklebust
<trondmy@primarydata.com> wrote:
>
>> On Sep 23, 2016, at 14:25, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Fri, Sep 23, 2016 at 2:08 PM, Trond Myklebust
>> <trondmy@primarydata.com> wrote:
>>>
>>>> On Sep 23, 2016, at 13:59, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> On Fri, Sep 23, 2016 at 1:45 PM, Trond Myklebust
>>>> <trondmy@primarydata.com> wrote:
>>>>>
>>>>>> On Sep 23, 2016, at 13:40, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>
>>>>>> If we instead bump the sequence number in the case of interrupted an=
d do:
>>>>>
>>>>> You have no guarantees that the server has seen and processed the ope=
ration.
>>>>
>>>> That is correct, i have tested the patch and made server never to
>>>> receive the operation and client have an interrupted slot. On the next
>>>> operation the server will complain back with SEQ_MISORDERED. Client
>>>> can recover from this operation. Client can not recover from "Remote
>>>> EIO=E2=80=9D.
>>>>
>>>
>>> Why not?
>>
>> When XDR layer returns EREMOTEIO it's not handled by the NFS error
>> recovery (are you suggesting we should?)  and returns that to the
>> application.
>>
>
> I=E2=80=99m saying that if we get a SEQ_MISORDERED due to a previous inte=
rrupt on that slot, then we should ignore the error in task->tk_status, and=
 just retry after bumping the slot seqid.
>

I'm confused where your objection lies. Are you ok with bumping the
sequence # when task->tk_status =3D 1 and saying that we should still
keep the code that I deleted in the 2nd chunk of the patch that bumped
the seqid on getting SEQ_MISORDERED due to a previously interrupted
slot?
Wouldn't that create a difference of 2 slots for the server that has
received the original request?
