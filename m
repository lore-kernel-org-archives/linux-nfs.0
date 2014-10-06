Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:44185 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbaJFOM5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Oct 2014 10:12:57 -0400
Received: by mail-ig0-f181.google.com with SMTP id r10so2792057igi.8
        for <linux-nfs@vger.kernel.org>; Mon, 06 Oct 2014 07:12:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtT39EBPx1SQTn3hFHBNuLsSoBdkSOYWHYRQ=j8vpVjB_A@mail.gmail.com>
References: <CAN-5tyF4oCkmHskT02GceF=CR1mYZc3uwm0tLf2fd39-XeyjRg@mail.gmail.com>
	<CAHQdGtT39EBPx1SQTn3hFHBNuLsSoBdkSOYWHYRQ=j8vpVjB_A@mail.gmail.com>
Date: Mon, 6 Oct 2014 10:12:56 -0400
Message-ID: <CAN-5tyGVfAQ+ZBp0hSMyRMHHWL3iP=h5XzaFrsLRf02rSH1ZHQ@mail.gmail.com>
Subject: Re: [bug] open owner value is always the same
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Aren't sequence slots shared by the same open owners?

The problem I'm seeing is that a client with an outstanding open can't
respond to a delegation return because sequenced hasn't been
confirmed. I think it's problematic when there are two clients each
holding delegations and each sending an open. The server tries to
recall the delegations but neither clients will reply until the server
returns an open to the outstanding open. The server will try and not
reply to the outstanding opens until the delegations are returned.



On Mon, Oct 6, 2014 at 9:57 AM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> Hi Olga,
>
> On Mon, Oct 6, 2014 at 9:48 AM, Olga Kornievskaia
> <olga.kornievskaia@gmail.com> wrote:
>> The spec says that open owner needs to be different for different
>> files yet the code returns the same value.
>>
>> It is not clear to me what's broken about ida_get_new() that's used
>> for generation of the owner ids.
>>
>> Can somebody comment on this?
>>
>
> As far as I know, there is no requirement in either NFSv4 or NFSv4.1
> that open owners be different for each file. In NFSv4.1 there is a
> requirement that they be unique to each credential/principal, but only
> if you negotiate EXCHGID4_FLAG_BIND_PRINC_STATEID.
>
> The current choice of scheme where we share open_owners between files
> was largely motivated by a desire not to overload the NFSv4.0 servers
> with lots of open_owner structures. In NFSv4.0, those structures are
> required to be cached by the server for a while after the file has
> been closed.
>
> Cheers
>   Trond
>
>
> --
> Trond Myklebust
>
> Linux NFS client maintainer, PrimaryData
>
> trond.myklebust@primarydata.com
