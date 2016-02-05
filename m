Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34437 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755354AbcBERBW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 12:01:22 -0500
Received: by mail-ig0-f177.google.com with SMTP id ik10so44742030igb.1
        for <linux-nfs@vger.kernel.org>; Fri, 05 Feb 2016 09:01:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtSETwRy7ry_ZkMo5M1uTwG6hvWMUmYRkJjgDob+g-RwUA@mail.gmail.com>
References: <CAN-5tyFJNCsSM=pccUnQmtq6ZMDdHNAmxOBZGYV2_0iNzfLsMQ@mail.gmail.com>
	<CAHQdGtSETwRy7ry_ZkMo5M1uTwG6hvWMUmYRkJjgDob+g-RwUA@mail.gmail.com>
Date: Fri, 5 Feb 2016 12:01:21 -0500
Message-ID: <CAN-5tyH37QCVM_bCufV1caoYFF2Zi_ZJr-RyaQrWdwFsR5Y4SQ@mail.gmail.com>
Subject: Re: Question about XID use in sunrpc
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 5, 2016 at 11:44 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Fri, Feb 5, 2016 at 10:37 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> I have a question regarding the implementation of sunrpc use of XID
>> when the client receives an AUTH_ERROR. The code (clnt.c line 1933)
>> explicitly comments that a new XID should be acquired and releases the
>> currently rpc task (and gets a new one). Why is that? Since the
>> operation is "replayed" but with the new credentials, why shouldn't
>> the same XID be used?
>>
>> The RPC RFC says that XID is used by the server to detect
>> retransmissions. It's not clear if in the specs means "retransmission"
>> == tcp retransmissions. If so then it explains why the client uses the
>> same XID.
>>
>
> The questions you are asking come under the header "RPC lore" rather
> than "RPC law". The use of XIDs as a basis for replay caching is not
> speced out in any RFC. The closest thing we have in the form of
> documentation is Ric Werme's presentation at the 1996 Connectathon:
> http://nfsv4bat.org/Documents/ConnectAThon/1996/werme1.pdf
>
> Basically, those comments are there in the Linux code to denote issues
> found when interoperability testing with server implementations that
> are probably now long dead, but might still be in use somewhere.

Would you consider changing this to use the same XID in case of
redoing the operation due to the AUTH_ERROR?

The issue it causes (one of the) server's implementation is of the
following nature:
1. client sends an operation to the server. the server process the
operation but before replying back to the server has an issue and
resets the connection.
2. client re-establishes the connection and replays the RPC. the
server now fails with the AUTH_ERROR.
3. client establishes a new connection and replays the same NFS
operation over the new XID. The server cached the operation but since
the last operation arrives with the new XID it won't find the entry in
the cache. It's problematic when the operation is like REMOVE.

I realize this is why nfs4.1 session were introduce to solve these
non-idenpotency issues but using the same XID seems like the right
idea since it is the same operation.

If you don't have objections to the change, I can ask on the IETF list
to see if any servers will object to such change.

>
> Cheers
>  Trond
