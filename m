From: Ingo Molnar <mingo@elte.hu>
Subject: Re: nfs client lockdep warning
Date: Mon, 12 Jan 2009 13:10:39 +0100
Message-ID: <20090112121039.GA27332@elte.hu>
References: <20090108203658.GE19312@fieldses.org> <1231447707.7179.10.camel@heimdal.trondhjem.org> <20090108212056.GF19312@fieldses.org> <20090109043315.GA12139@gondor.apana.org.au> <1231480697.11687.522.camel@twins> <20090109062333.GB13304@gondor.apana.org.au> <1231483868.11687.523.camel@twins> <20090109202939.GA5466@fieldses.org> <1231761731.4371.7.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
	Trond Myklebust <trond@netapp.com>,
	Nick Piggin <npiggin@suse.de>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:35545 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751316AbZALMLD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jan 2009 07:11:03 -0500
In-Reply-To: <1231761731.4371.7.camel@laptop>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> Subject: lockdep,mm: fix might_fault() annotation
> 
> Some code (nfs/sunrpc) uses socket ops on kernel memory while holding
> the mmap_sem, this is safe because kernel memory doesn't get paged out,
> therefore we'll never actually fault, and the might_fault() annotations
> will generate false positives.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

applied to tip/core/urgent, thanks guys!

I also added a:

 Reported-by: "J. Bruce Fields" <bfields@fieldses.org>

line as we always want to preserve the chain of bug reports and attribute 
them.

	Ingo
