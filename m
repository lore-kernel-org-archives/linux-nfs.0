Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:62431 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbbAXBBx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Jan 2015 20:01:53 -0500
Received: by mail-vc0-f175.google.com with SMTP id la4so167440vcb.6
        for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2015 17:01:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <96B46DBF-7AB7-4851-A7FB-A308B2C78C7C@oracle.com>
References: <E4A8B62E-BCFC-497F-B134-ECD90F232804@oracle.com>
	<CAABAsM4y_f889vvDthy52gdr_=8Rf6BfwN5_A15wdRwMg_HP=w@mail.gmail.com>
	<96B46DBF-7AB7-4851-A7FB-A308B2C78C7C@oracle.com>
Date: Fri, 23 Jan 2015 20:01:52 -0500
Message-ID: <CAHQdGtQt2JGUZFUR6k_9SKhzyVR0HcSUzVqN9u=ScJQyar2jNw@mail.gmail.com>
Subject: Re: NFSv4.1 backchannel for RDMA
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 23, 2015 at 6:28 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
> On Jan 23, 2015, at 5:44 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
>
>> On Fri, Jan 23, 2015 at 4:00 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> Hi-
>>>
>>> I’d like to restart the discussion in this thread:
>>>
>>>  http://marc.info/?l=linux-nfs&m=141348840527766&w=2
>>>
>>> It seems to me there are two main points:
>>>
>>> 1.  Is bi-directional RPC on RPC/RDMA transports desirable?
>>>
>>> 2.  Is a secondary backchannel-only transport adequate and reliable?
>>>
>>> I’ll try to summarize the current thinking.
>>>
>>>
>>> Question 1:
>>>
>>> The main reason to plumb bi-RPC into RPC/RDMA is that no changes to
>>> the NFSv4.1 client upper layers would be needed. I think we also
>>> agree that:
>>>
>>> - There is no performance benefit. CB operations typically lack
>>>   significant payload, are infrequent, and can be long-running.
>
>  [ . . . snip . . . ]
>
>>> - To handle large payloads (possibly required by certain pNFS
>>>   CB operations), an NFSv4.1 client would need to handle
>>>   RDMA_NOMSG type calls over the backchannel. This would require
>>>   the client to perform RDMA READ and WRITE operations against the
>>>   server (the opposite of what happens in the forward channel).
>>
>> Only if it wants to. The maximum size of backchannel payloads is
>> negotiated at session creation time. Both the server and the client
>> have to opportunity to negotiate that limit down to something
>> reasonable.
>>
>> I'm assuming that you are referring to CB_NOTIFY_DEVICEID because it
>> takes an array argument? There is nothing stopping the server from
>> breaking that down into multiple calls if the payload is too large.
>> Ditto for CB_NOTIFY, btw.
>
> As long as all large CB operations can be broken down in this way,
> then this is very helpful, and all NFSv4.1 CB operations on an RDMA
> backchannel can use only RDMA SEND.
>
> I’ll explore the mechanism for limiting the size of backchannel
> messages.
>
>>> There is some interest in prototyping an RPC/RDMA transport that is
>>> capable of bi-directional RPC. A prototype would help us determine
>>> whether there are subtle problems that make bi-RPC impossible for
>>> RPC/RDMA, and identify any spec gaps that need to be addressed.
>>> Because of the development cost and lack of perceptible benefits, a
>>> prototype has not been attempted so far.
>>>
>>> Would it be productive for a bi-capable RPC/RDMA transport prototype
>>> to be pursued in Linux?
>>
>> Yes.
>
> OK, we’ll look into it.
>
>>> Question 2:
>>>
>>> The Solaris client and server already implement a sidecar TCP
>>> backchannel for NFSv4.1. This is something that can be tested.
>>> Further, I think we agree that:
>>>
>>> - Servers are required to support a separate backchannel and
>>>   forward channel transport, and both sides can detect what is
>>>   supported with CREATE_SESSION. However, there are no existing
>>>   implementations that have deployed this kind of logic widely.
>>>
>>> - The addition of a separate backchannel-only connection is
>>>   considered session trunking, which is regarded as potentially
>>>   hazardous. We haven’t identified exactly what the  hazards might
>>>   be when the second connection handles only backchannel activity.
>>>
>>> - Although there are few or no server changes required to support
>>>   a secondary backchannel, clients would have to be modified to
>>>   establish this connection when one or both sides do not support
>>>   a backchannel on the main transport and the server asserts the
>>>   SEQ4_STATUS_CB_PATH_DOWN flag.
>>>
>>> - We have some confidence that creation of the second backchannel-
>>>   only connection followed by BIND_CONN_TO_SESSION appears to be
>>>   adequate and robust. However, the salient recovery edge conditions
>>>   when a secondary backchannel transport is being used still need to
>>>   be identified.
>>>
>>> What further investigation is needed to be confident that the sidecar
>>> solution is adequate and appropriate?
>>
>> Offhand I can think of at least 2 issues:
>>
>> - How does the client determine which IP address to use for the TCP channel?
>
> It uses the same IP address that was used for the RDMA connection.

a) That's not documented in any RFC AFAIK.
b) That's not going to work in the general "service address" case
mentioned earlier in the thread.

>> - How does the client and server detect that the TCP connection is
>> still up when there is no activity on it?
>
> The server can perform CB_NULL regularly, for example.
>
> We definitely had this problem in prototype, but I don’t recall how
> it was resolved; I just remember that it was addressed appropriately
> on the server.

Again, this needs support in one of the RFCs.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com
