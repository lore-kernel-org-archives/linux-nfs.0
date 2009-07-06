From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: sk_lock: inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W}
	usage
Date: Mon, 6 Jul 2009 18:52:16 +0800
Message-ID: <20090706105216.GA19124@gondor.apana.org.au>
References: <20090608023757.GA6244@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52565 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757716AbZGFKwP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jul 2009 06:52:15 -0400
In-Reply-To: <20090608023757.GA6244@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> This lockdep warning appears when doing stress memory tests over NFS.
> 
> page reclaim => nfs_writepage => tcp_sendmsg => lock sk_lock
> 
> tcp_close => lock sk_lock => tcp_send_fin => alloc_skb_fclone => page reclaim

Well perhaps not this particular path, but it is certainly possible
if an existing NFS socket dies and NFS tries to reestablish it.

I suggest that NFS should utilise the sk_allocation field and
set an appropriate value.  Note that you may have to patch TCP
so that it uses sk_allocation everywhere necessary, e.g., in
tcp_send_fin.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
