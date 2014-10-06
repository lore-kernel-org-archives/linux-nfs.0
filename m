Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f171.google.com ([209.85.213.171]:60231 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbaJFOtH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 10:49:07 -0400
Received: by mail-ig0-f171.google.com with SMTP id h15so2612774igd.10
        for <linux-nfs@vger.kernel.org>; Mon, 06 Oct 2014 07:49:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyGVfAQ+ZBp0hSMyRMHHWL3iP=h5XzaFrsLRf02rSH1ZHQ@mail.gmail.com>
References: <CAN-5tyF4oCkmHskT02GceF=CR1mYZc3uwm0tLf2fd39-XeyjRg@mail.gmail.com>
	<CAHQdGtT39EBPx1SQTn3hFHBNuLsSoBdkSOYWHYRQ=j8vpVjB_A@mail.gmail.com>
	<CAN-5tyGVfAQ+ZBp0hSMyRMHHWL3iP=h5XzaFrsLRf02rSH1ZHQ@mail.gmail.com>
Date: Mon, 6 Oct 2014 10:49:06 -0400
Message-ID: <CAABAsM5MZxgpSd2c8rc4BxVVCjxwBgT2n8+uUONNrTX6AvJudQ@mail.gmail.com>
Subject: Re: [bug] open owner value is always the same
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <olga.kornievskaia@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 6, 2014 at 10:12 AM, Olga Kornievskaia
<olga.kornievskaia@gmail.com> wrote:
> Aren't sequence slots shared by the same open owners?
>
> The problem I'm seeing is that a client with an outstanding open can't
> respond to a delegation return because sequenced hasn't been
> confirmed. I think it's problematic when there are two clients each
> holding delegations and each sending an open. The server tries to
> recall the delegations but neither clients will reply until the server
> returns an open to the outstanding open. The server will try and not
> reply to the outstanding opens until the delegations are returned.

I'm not sure that I understand.

Why should the server refuse to respond to OPEN calls just because a
delegation recall is outstanding? That sounds like a catastrophic
design for a server. How is the client going to convert its cached
open/lock state into open stateids and lock stateids if the server
won't respond to OPEN calls for that file?

If the server cannot respond to the OPEN because it conflicts with a
delegation being recalled, then the right thing to do is to return
NFS4ERR_DELAY. That allows the client to make progress on other OPEN
requests that may be required in order to return the conflicting
delegation, and that may be serialised behind that blocked OPEN.
I can imagine this might be the case if the client holds a delegation
for a file, and then is asked to OPEN a hard link to the same file.
The client has no way to know a priori that it is opening the same
file through the hard link, so it doesn't know that it conflicts with
the delegation.

Cheers
  Trond

>
> On Mon, Oct 6, 2014 at 9:57 AM, Trond Myklebust
> <trond.myklebust@primarydata.com> wrote:
>> Hi Olga,
>>
>> On Mon, Oct 6, 2014 at 9:48 AM, Olga Kornievskaia
>> <olga.kornievskaia@gmail.com> wrote:
>>> The spec says that open owner needs to be different for different
>>> files yet the code returns the same value.
>>>
>>> It is not clear to me what's broken about ida_get_new() that's used
>>> for generation of the owner ids.
>>>
>>> Can somebody comment on this?
>>>
>>
>> As far as I know, there is no requirement in either NFSv4 or NFSv4.1
>> that open owners be different for each file. In NFSv4.1 there is a
>> requirement that they be unique to each credential/principal, but only
>> if you negotiate EXCHGID4_FLAG_BIND_PRINC_STATEID.
>>
>> The current choice of scheme where we share open_owners between files
>> was largely motivated by a desire not to overload the NFSv4.0 servers
>> with lots of open_owner structures. In NFSv4.0, those structures are
>> required to be cached by the server for a while after the file has
>> been closed.
>>
>> Cheers
>>   Trond
>>
>>
>> --
>> Trond Myklebust
>>
>> Linux NFS client maintainer, PrimaryData
>>
>> trond.myklebust@primarydata.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
