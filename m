From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/37] SUNRPC: Use GFP_NOFS when allocating credentials
Date: Fri, 13 Jun 2008 17:31:47 -0400
Message-ID: <20080613213147.GQ8501@fieldses.org>
References: <20080612192159.24528.43756.stgit@localhost.localdomain> <20080612192200.24528.65570.stgit@localhost.localdomain> <20080613211743.GP8501@fieldses.org> <1213392377.19011.80.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:48896 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192AbYFMVbs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 17:31:48 -0400
In-Reply-To: <1213392377.19011.80.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2008 at 05:26:17PM -0400, Trond Myklebust wrote:
> On Fri, 2008-06-13 at 17:17 -0400, J. Bruce Fields wrote:
> > On Thu, Jun 12, 2008 at 03:22:00PM -0400, Trond Myklebust wrote:
> > > Since the credentials may be allocated during the call to rpc_new_task(),
> > > which again may be called by a memory allocator...
> > 
> > Most of these are only called in gssd  process's context when it
> > performs the downcall.  Which doesn't change the fact that they're
> > needed for the rpc_new_task() to succeed, OK, so this isn't an objection
> > to this patch--but is there any plan for how we'll deal with e.g. memory
> > allocations that gssd does on its own?
> 
> You mean alloc_enc_pages()? We should really try to avoid sleeping
> there...

No, that may be a problem too, but I mean: if we're worried about a
deadlock due to some allocations that gssd performs on the downcall at
the end of the context initiation, then shouldn't we also be worried
about all the other allocations that gssd performs itself?

--b.
