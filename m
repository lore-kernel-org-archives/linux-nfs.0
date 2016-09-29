Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36520 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932321AbcI2OtO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2016 10:49:14 -0400
Received: by mail-it0-f52.google.com with SMTP id u134so114605484itb.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Sep 2016 07:49:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1475159680.4676.65.camel@redhat.com>
References: <cover.1475048434.git.pabeni@redhat.com> <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
 <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
 <1475141514.4676.28.camel@redhat.com> <1475155472.28155.164.camel@edumazet-glaptop3.roam.corp.google.com>
 <1475157674.4676.52.camel@redhat.com> <1475158408.28155.166.camel@edumazet-glaptop3.roam.corp.google.com>
 <1475159680.4676.65.camel@redhat.com>
From: Eric Dumazet <edumazet@google.com>
Date: Thu, 29 Sep 2016 07:49:11 -0700
Message-ID: <CANn89iKc=GEesKcB3OG5_wFBnZWiCBLCDkz3k5FgJFVDw-rOyQ@mail.gmail.com>
Subject: Re: [PATCH net-next v3 2/3] udp: implement memory accounting helpers
To: Paolo Abeni <pabeni@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 29, 2016 at 7:34 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Thu, 2016-09-29 at 07:13 -0700, Eric Dumazet wrote:
>> On Thu, 2016-09-29 at 16:01 +0200, Paolo Abeni wrote:
>>
>> > When we reach __sk_mem_reduce_allocated() we are sure we can free the
>> > specified amount of memory, so we only need to ensure consistent
>> > sk_prot->memory_allocated updates. The current atomic operation suffices
>> > to this.
>>
>> Then why are you updating sk->sk_forward_alloc using racy operations ?
>>
>> If this is not needed or racy, do not do it.
>
> Thank you for all the feedback.
>
> The actual forward allocated memory value is:
>
> atomic_read(&up->mem_allocated) - atomic_read(&sk->sk_rmem_alloc).
>
> sk_forward_alloc is updated only to hint to the user space the forward
> allocated memory value via the diag interface.
>
> If such information is not needed we can drop the update, and
> sk_forward_alloc will always be seen as 0 even when the socket has some
> forward allocation.

The information is needed and we want an accurate one, really.

Think about debugging on a live server, some stuck or mad sockets ;)

Please consider adding a proper accessor, able to deal with the UDP
peculiarities.


int sk_forward_alloc_get(const struct sock *sk)
{
        if (sk is not UDP)
           return sk->sk_forward_alloc;

       return the precise amount using the private fields that UDP maintains,
}


Then use this accessor in these places :

net/ipv4/af_inet.c:155: WARN_ON(sk->sk_forward_alloc);
net/core/sock_diag.c:66:        mem[SK_MEMINFO_FWD_ALLOC] =
sk->sk_forward_alloc;
net/ipv4/inet_diag.c:191:                       .idiag_fmem =
sk->sk_forward_alloc,
net/sched/em_meta.c:462:        dst->value = sk->sk_forward_alloc;

Thanks.
