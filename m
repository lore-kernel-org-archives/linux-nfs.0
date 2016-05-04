Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbcEDEyq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 May 2016 00:54:46 -0400
Date: Wed, 04 May 2016 00:54:43 -0400 (EDT)
Message-Id: <20160504.005443.219521798076710212.davem@davemloft.net>
To: eric.dumazet@gmail.com
Cc: romieu@fr.zoreil.com, festevam@gmail.com, edumazet@google.com,
        chuck.lever@oracle.com, trond.myklebust@primarydata.com,
        netdev@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next] tcp: fix lockdep splat in tcp_snd_una_update()
From: David Miller <davem@davemloft.net>
In-Reply-To: <1462319763.5535.329.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160503223149.GA19739@electric-eye.fr.zoreil.com>
	<1462314901.5535.316.camel@edumazet-glaptop3.roam.corp.google.com>
	<1462319763.5535.329.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 May 2016 16:56:03 -0700

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

Applied.
