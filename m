From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/37] SUNRPC: Use GFP_NOFS when allocating credentials
Date: Fri, 13 Jun 2008 17:58:03 -0400
Message-ID: <20080613215803.GB14338@fieldses.org>
References: <20080612192159.24528.43756.stgit@localhost.localdomain> <20080612192200.24528.65570.stgit@localhost.localdomain> <20080613211743.GP8501@fieldses.org> <1213392377.19011.80.camel@localhost> <20080613213147.GQ8501@fieldses.org> <1213392894.19011.82.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56840 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754003AbYFMV6F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 17:58:05 -0400
In-Reply-To: <1213392894.19011.82.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 13, 2008 at 05:34:54PM -0400, Trond Myklebust wrote:
> On Fri, 2008-06-13 at 17:31 -0400, J. Bruce Fields wrote:
> > No, that may be a problem too, but I mean: if we're worried about a
> > deadlock due to some allocations that gssd performs on the downcall at
> > the end of the context initiation, then shouldn't we also be worried
> > about all the other allocations that gssd performs itself?
> 
> Definitely.

Do you have any ideas (however speculative) about how we'll deal with
that?

--b.
