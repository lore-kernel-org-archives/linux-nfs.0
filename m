Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36462 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756907AbcEDB0v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 May 2016 21:26:51 -0400
MIME-Version: 1.0
In-Reply-To: <1462319763.5535.329.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160503223149.GA19739@electric-eye.fr.zoreil.com>
	<1462314901.5535.316.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462319763.5535.329.camel@edumazet-glaptop3.roam.corp.google.com>
Date: Tue, 3 May 2016 22:26:50 -0300
Message-ID: <CAOMZO5AL6Vd7jdFWdSb_TokSNWW7x19TSO__w22B6k7wr6VPxw@mail.gmail.com>
Subject: Re: [PATCH net-next] tcp: fix lockdep splat in tcp_snd_una_update()
From: Fabio Estevam <festevam@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 3, 2016 at 8:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> tcp_snd_una_update() and tcp_rcv_nxt_update() call
> u64_stats_update_begin() either from process context or BH handler.
>
> This triggers a lockdep splat on 32bit & SMP builds.
>
> We could add u64_stats_update_begin_bh() variant but this would
> slow down 32bit builds with useless local_disable_bh() and
> local_enable_bh() pairs, since we own the socket lock at this point.
>
> I add sock_owned_by_me() helper to have proper lockdep support
> even on 64bit builds, and new u64_stats_update_begin_raw()
> and u64_stats_update_end_raw methods.
>
> Fixes: c10d9310edf5 ("tcp: do not assume TCP code is non preemptible")
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Diagnosed-by: Francois Romieu <romieu@fr.zoreil.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Thanks for the fix, Eric and Francois! This allows me to do NFS boot again:

Tested-by: Fabio Estevam <fabio.estevam@nxp.com>
