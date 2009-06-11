From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [patch 1/1] sunrpc: align cache_clean work's timer
Date: Thu, 11 Jun 2009 14:31:40 -0400
Message-ID: <20090611183140.GA16066@fieldses.org>
References: <200906101952.n5AJqLZb006065@imap1.linux-foundation.org> <20090611.025251.227156574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, trond.myklebust@fys.uio.no,
	linux-nfs@vger.kernel.org, anton@samba.org, neilb@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:34392 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753947AbZFKSbm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Jun 2009 14:31:42 -0400
In-Reply-To: <20090611.025251.227156574.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 11, 2009 at 02:52:51AM -0700, David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Wed, 10 Jun 2009 12:52:21 -0700
> 
> > From: Anton Blanchard <anton@samba.org>
> > 
> > Align cache_clean work.
> > 
> > Signed-off-by: Anton Blanchard <anton@samba.org>
> > Cc: Neil Brown <neilb@suse.de>
> > Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
> > Cc: "David S. Miller" <davem@davemloft.net>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thanks, applied for 2.6.31.

--b.
