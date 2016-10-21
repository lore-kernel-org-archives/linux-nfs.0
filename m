Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35464 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933253AbcJUVNF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2016 17:13:05 -0400
Message-ID: <1477084383.7065.87.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v6 1/3] net/socket: factor out helpers for
 memory and queue manipulation
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
Date: Fri, 21 Oct 2016 14:13:03 -0700
In-Reply-To: <14784e6382342c2184929ef2959e7c11faf8ff8e.1477043395.git.pabeni@redhat.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <14784e6382342c2184929ef2959e7c11faf8ff8e.1477043395.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-10-21 at 13:55 +0200, Paolo Abeni wrote:
> Basic sock operations that udp code can use with its own
> memory accounting schema. No functional change is introduced
> in the existing APIs.
> 
> v4 -> v5:
>   - avoid whitespace changes
> 
> v2 -> v4:
>   - avoid exporting __sock_enqueue_skb
> 
> v1 -> v2:
>   - avoid export sock_rmem_free
> 
> Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>
> ---

Acked-by: Eric Dumazet <edumazet@google.com>


