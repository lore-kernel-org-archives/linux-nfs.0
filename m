Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34227 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752079AbcLFSHy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Dec 2016 13:07:54 -0500
Received: by mail-io0-f196.google.com with SMTP id r94so8115509ioe.1
        for <linux-nfs@vger.kernel.org>; Tue, 06 Dec 2016 10:07:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <877f7e58yo.fsf@notabene.neil.brown.name>
References: <87oa0r584c.fsf@notabene.neil.brown.name> <CAN-5tyHrWMj54cvj3PVO+8Yxk+0NK9ey=X7VU6WXKv-mswh-xw@mail.gmail.com>
 <877f7e58yo.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 6 Dec 2016 13:07:43 -0500
Message-ID: <CAN-5tyHT9X9ULCDT0iPkMtgo4eMiRLVGVuzabmZXMePv8FwXFw@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: fix refcounting problems with auth_gss messages.
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 5, 2016 at 5:04 PM, NeilBrown <neilb@suse.com> wrote:
> On Tue, Dec 06 2016, Olga Kornievskaia wrote:
>
>> On Sun, Dec 4, 2016 at 11:10 PM, NeilBrown <neilb@suse.com> wrote:
>>>
>>> There are two problems with refcounting of auth_gss messages.
>>>
>>> First, the reference on the pipe->pipe list (taken by a call
>>> to rpc_queue_upcall()) is not counted.  It seems to be
>>> assumed that a message in pipe->pipe will always also be in
>>> pipe->in_downcall, where it is correctly reference counted.
>>>
>>> However there is no guaranty of this.  I have a report of a
>>> NULL dereferences in rpc_pipe_read() which suggests a msg
>>> that has been freed is still on the pipe->pipe list.
>>>
>>> One way I imagine this might happen is:
>>> - message is queued for uid=U and auth->service=S1
>>> - rpc.gssd reads this message and starts processing.
>>>   This removes the message from pipe->pipe
>>> - message is queued for uid=U and auth->service=S2
>>> - rpc.gssd replies to the first message. gss_pipe_downcall()
>>>   calls __gss_find_upcall(pipe, U, NULL) and it finds the
>>>   *second* message, as new messages are placed at the head
>>>   of ->in_downcall, and the service type is not checked.
>>
>> Correct "service" was/is not a part of the protocol between the kernel
>> and gssd. So that's why the kernel can't match what's coming from gssd
>> to a particular waiting upcall.
>>
>>> - This second message is removed from ->in_downcall and freed
>>>   by gss_release_msg() (even though it is still on pipe->pipe)
>>> - rpc.gssd tries to read another message, and dereferences a pointer
>>>   to this message that has just been freed.
>>
>> Agreed. This is a problem.
>>
>> Doesn't the problem still exist even with this patch because
>> gss_add_msg() adds the msg onto the in_downcall() list? So gssd in
>> __gss_fin_upcall() can find the 2nd upcall even before the 2nd msg is
>> added to the pipe->pipe()?
>
> The use-after-free problem is solved I think.  It doesn't really make
> any difference if the down-call arrives before or after
> rpc_queue_upcall() is called.  The msg will still not be freed before it
> is removed from both lists.
>

Sorry I don't see it.

Thread 1 adds an upcall and it's getting processed by gssd.
Thread 2 executes gss_add_msg() which puts the message on the
in_downcall list. Context switch (before the atomic_inc()!).
Upcall comes back from the gssd, finds msg from Thread2 in_downcall
list. gss_release_msg() will dec the counter to 0 and will remove the
msg.
