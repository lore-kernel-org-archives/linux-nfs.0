Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:44371 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751288AbdLGQKS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Dec 2017 11:10:18 -0500
Received: by mail-vk0-f42.google.com with SMTP id s197so5173337vkh.11
        for <linux-nfs@vger.kernel.org>; Thu, 07 Dec 2017 08:10:18 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAABAsM57k0E32ywgW=qdhFbeHctcUivM9mkuuA1qbfB9F7Rvyg@mail.gmail.com>
References: <CAN-5tyEe2gEgmSnZju7MjgrFR_YK1PrLx2NpxJn5Ks88PEz__g@mail.gmail.com>
 <CAABAsM57k0E32ywgW=qdhFbeHctcUivM9mkuuA1qbfB9F7Rvyg@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 7 Dec 2017 11:10:16 -0500
Message-ID: <CAN-5tyEmwgo7ea1WJ-0nRE+Jz+b9rb97GkYEmFyq_C+8nr1kTw@mail.gmail.com>
Subject: Re: [nfsv4] questing about NLM LOCK, CANCEL UNLOCK
To: Trond Myklebust <trondmy@gmail.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Cc: "nfsv4@ietf.org" <nfsv4@ietf.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok. I thought that because RFC1813 covers NLM operations that it is.

I will extend this question to the Linux NFS mailing list as the
client implementation I'm interested is Linux.

On Thu, Dec 7, 2017 at 10:59 AM, Trond Myklebust <trondmy@gmail.com> wrote:
> Hi Olga,
>
> NLM isn't an IETF protocol.
>
> Cheers
>   Trond
>
> On 7 December 2017 at 10:57, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> Hi folks,
>>
>> I'm looking for guidance for what are responsibilities of the client
>> or server to solve the following situation.
>>
>> Client application is acquiring a blocking lock but shortly after that
>> application is killed via ctrl-C. NFS client sent out NLM_LOCK but
>> hasn't gotten a reply yet as ctrl-c arrived. To clean up, the client
>> is sending CANCEL and UNLOCK to the server.
>>
>> Server ends up processing CANCEL and UNLOCK first (for whatever reason
>> one legitimate one could be network re-ordered packets) and server has
>> no state so it's just sending GRANTED replies back (which seems to be
>> a legitimate thing to do). Then server processes LOCK and replies to
>> the client.
>>
>> Now we are in the situation where lock was granted to a client that
>> doesn't know it's holding one and it prevents other clients from
>> grabbing this lock.
>>
>> Is there a solution or this is broken protocol?
>>
>> Should it be client's responsibility to notice that it received a LOCK
>> reply for which it wasn't waiting and always follow up with an UNLOCK?
>>
>> Thank you.
>>
>> _______________________________________________
>> nfsv4 mailing list
>> nfsv4@ietf.org
>> https://www.ietf.org/mailman/listinfo/nfsv4
>
>
