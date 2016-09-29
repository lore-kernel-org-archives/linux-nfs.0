Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52398 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932221AbcI2O7L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Sep 2016 10:59:11 -0400
Message-ID: <1475161147.4676.70.camel@redhat.com>
Subject: Re: [PATCH net-next v3 2/3] udp: implement memory accounting helpers
From: Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2016 16:59:07 +0200
In-Reply-To: <CANn89iKc=GEesKcB3OG5_wFBnZWiCBLCDkz3k5FgJFVDw-rOyQ@mail.gmail.com>
References: <cover.1475048434.git.pabeni@redhat.com>
         <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
         <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
         <1475141514.4676.28.camel@redhat.com>
         <1475155472.28155.164.camel@edumazet-glaptop3.roam.corp.google.com>
         <1475157674.4676.52.camel@redhat.com>
         <1475158408.28155.166.camel@edumazet-glaptop3.roam.corp.google.com>
         <1475159680.4676.65.camel@redhat.com>
         <CANn89iKc=GEesKcB3OG5_wFBnZWiCBLCDkz3k5FgJFVDw-rOyQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-29 at 07:49 -0700, Eric Dumazet wrote:
> On Thu, Sep 29, 2016 at 7:34 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> > On Thu, 2016-09-29 at 07:13 -0700, Eric Dumazet wrote:
> >> On Thu, 2016-09-29 at 16:01 +0200, Paolo Abeni wrote:
> >>
> >> > When we reach __sk_mem_reduce_allocated() we are sure we can free the
> >> > specified amount of memory, so we only need to ensure consistent
> >> > sk_prot->memory_allocated updates. The current atomic operation suffices
> >> > to this.
> >>
> >> Then why are you updating sk->sk_forward_alloc using racy operations ?
> >>
> >> If this is not needed or racy, do not do it.
> >
> > Thank you for all the feedback.
> >
> > The actual forward allocated memory value is:
> >
> > atomic_read(&up->mem_allocated) - atomic_read(&sk->sk_rmem_alloc).
> >
> > sk_forward_alloc is updated only to hint to the user space the forward
> > allocated memory value via the diag interface.
> >
> > If such information is not needed we can drop the update, and
> > sk_forward_alloc will always be seen as 0 even when the socket has some
> > forward allocation.
> 
> The information is needed and we want an accurate one, really.
> 
> Think about debugging on a live server, some stuck or mad sockets ;)
> 
> Please consider adding a proper accessor, able to deal with the UDP
> peculiarities.

Nice suggestion, thanks! I'll try that in v4. Perhaps is worth adding a
struct proto helper for this ?

I'm sorry, but I'll not be in Tokyo, so I'll probably produce some
traffic on netdev in the meanwhile.

Cheers,

Paolo

