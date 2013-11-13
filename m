Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59462 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753775Ab3KMQYp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 11:24:45 -0500
Date: Wed, 13 Nov 2013 11:24:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Shyam Kaushik <shyamnfs1@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Need help with NFS Server SUNRPC performance issue
Message-ID: <20131113162443.GK28033@fieldses.org>
References: <CA+uAZNPquD-JA1SDpFHtx9ZawQA5=o+fBigOTy+9NEiDL+hmyw@mail.gmail.com>
 <20131031141538.GA621@fieldses.org>
 <CA+uAZNO7VrBA1MLgGoqGpXGPHMMy0VF_3KBr93Y5w1M=ZO7s4w@mail.gmail.com>
 <20131104230244.GD8828@fieldses.org>
 <CA+uAZNOJg3Jeu8uyCEeHx71JwHwC0P0d=mx1BiyKnyoS04KUsw@mail.gmail.com>
 <20131105195810.GC23329@fieldses.org>
 <CA+uAZNNfchaju7GrHcwUQ1O5qnaoTxJt0W0bkmFyS7YJwxKJLQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+uAZNNfchaju7GrHcwUQ1O5qnaoTxJt0W0bkmFyS7YJwxKJLQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 06, 2013 at 12:57:38PM +0530, Shyam Kaushik wrote:
> Hi Bruce,
> 
> This hack works great. All 32 of configured NFSD threads end up doing
> nfsd_write() which is great & I get higher IOPs/bandwidth from NFS
> client side.
> 
> What do you think if we vary the signature of
> typedef __be32(*nfsd4_dec)(struct nfsd4_compoundargs *argp, void *);
> 
> to include an additional return argument of the size estimate. This
> way we get size estimate from the decoders (like nfsd4_decode_read
> could return this estimate as rd_length + overhead) & in the worst
> case if decoder says cant estimate (like a special return code -1) we
> dont do svc_reserve() & leave it like it is. So when we run through
> the compound we have a sum of size estimate & just do svc_reserve() at
> the end of nfsd4_decode_compound() like your hack has.
> 
> Does this sound reasonable to you? If not, perhaps can we just use the
> hack for now & worry about readdir etc when they support >4K buffer?

Yep.  Actually looking at it again I think it needs a couple more
special cases (for readlink, readdir), but that should be good enough
for now.

For the future.... I'd rather not add an extra argument to every encoder
but maybe that is the simplest thing to do.

--b.
