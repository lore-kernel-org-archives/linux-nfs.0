Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33602 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754325AbcI2ONb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Sep 2016 10:13:31 -0400
Message-ID: <1475158408.28155.166.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v3 2/3] udp: implement memory accounting helpers
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Date: Thu, 29 Sep 2016 07:13:28 -0700
In-Reply-To: <1475157674.4676.52.camel@redhat.com>
References: <cover.1475048434.git.pabeni@redhat.com>
         <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
         <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
         <1475141514.4676.28.camel@redhat.com>
         <1475155472.28155.164.camel@edumazet-glaptop3.roam.corp.google.com>
         <1475157674.4676.52.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-09-29 at 16:01 +0200, Paolo Abeni wrote:

> When we reach __sk_mem_reduce_allocated() we are sure we can free the
> specified amount of memory, so we only need to ensure consistent
> sk_prot->memory_allocated updates. The current atomic operation suffices
> to this.

Then why are you updating sk->sk_forward_alloc using racy operations ?

If this is not needed or racy, do not do it.

So that we can remove this annoying thing that a dynamic checker could
very well detect.



