Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34392 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751919AbcLGO6q (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Dec 2016 09:58:46 -0500
Received: by mail-io0-f196.google.com with SMTP id r94so13895942ioe.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Dec 2016 06:58:46 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <87wpfc4sgk.fsf@notabene.neil.brown.name>
References: <87oa0r584c.fsf@notabene.neil.brown.name> <CAN-5tyHrWMj54cvj3PVO+8Yxk+0NK9ey=X7VU6WXKv-mswh-xw@mail.gmail.com>
 <877f7e58yo.fsf@notabene.neil.brown.name> <CAN-5tyHT9X9ULCDT0iPkMtgo4eMiRLVGVuzabmZXMePv8FwXFw@mail.gmail.com>
 <87wpfc4sgk.fsf@notabene.neil.brown.name>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 7 Dec 2016 09:58:44 -0500
Message-ID: <CAN-5tyFNJsx3RcO_eETCP0O9W7Wb-BQUd9Huyz9-gK3h9ap3PA@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: fix refcounting problems with auth_gss messages.
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 6, 2016 at 5:12 PM, NeilBrown <neilb@suse.com> wrote:
> On Wed, Dec 07 2016, Olga Kornievskaia wrote:
>>>>
>>>> Agreed. This is a problem.
>>>>
>>>> Doesn't the problem still exist even with this patch because
>>>> gss_add_msg() adds the msg onto the in_downcall() list? So gssd in
>>>> __gss_fin_upcall() can find the 2nd upcall even before the 2nd msg is
>>>> added to the pipe->pipe()?
>>>
>>> The use-after-free problem is solved I think.  It doesn't really make
>>> any difference if the down-call arrives before or after
>>> rpc_queue_upcall() is called.  The msg will still not be freed before it
>>> is removed from both lists.
>>>
>>
>> Sorry I don't see it.
>
> Maybe we are looking at different code?
>
>>
>> Thread 1 adds an upcall and it's getting processed by gssd.
>> Thread 2 executes gss_add_msg() which puts the message on the
>> in_downcall list. Context switch (before the atomic_inc()!).
>
> gss_add_msg(), as of 4.9-rc8, is
>         spin_lock(&pipe->lock);
>         old = __gss_find_upcall(pipe, gss_msg->uid, gss_msg->auth);
>         if (old == NULL) {
>                 atomic_inc(&gss_msg->count);
>                 list_add(&gss_msg->list, &pipe->in_downcall);
>         } else
>                 gss_msg = old;
>         spin_unlock(&pipe->lock);
>
> so the gss_msg is added to in_downcall *after* the atomic_inc(), and the
> whole is protected by pipe->lock anyway so even if the atomic_inc() were
> delayed by the CPU reordering things, there would be no risk of
> gss_pipe_downcall() finding a gss_msg which didn't have the ->count
> elevated.
>

Ah, I missed the atomic_inc() in the gss_add_msg(). I was only looking
at your patch that did another atomic_inc(). Makes sense now.

> NeilBrown
>
>> Upcall comes back from the gssd, finds msg from Thread2 in_downcall
>> list. gss_release_msg() will dec the counter to 0 and will remove the
>> msg.
