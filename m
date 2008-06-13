From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 08/37] SUNRPC: Use GFP_NOFS when allocating credentials
Date: Fri, 13 Jun 2008 17:26:17 -0400
Message-ID: <1213392377.19011.80.camel@localhost>
References: <20080612192159.24528.43756.stgit@localhost.localdomain>
	 <20080612192200.24528.65570.stgit@localhost.localdomain>
	 <20080613211743.GP8501@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64349 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753939AbYFMV1L (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2008 17:27:11 -0400
In-Reply-To: <20080613211743.GP8501@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2008-06-13 at 17:17 -0400, J. Bruce Fields wrote:
> On Thu, Jun 12, 2008 at 03:22:00PM -0400, Trond Myklebust wrote:
> > Since the credentials may be allocated during the call to rpc_new_task(),
> > which again may be called by a memory allocator...
> 
> Most of these are only called in gssd  process's context when it
> performs the downcall.  Which doesn't change the fact that they're
> needed for the rpc_new_task() to succeed, OK, so this isn't an objection
> to this patch--but is there any plan for how we'll deal with e.g. memory
> allocations that gssd does on its own?

You mean alloc_enc_pages()? We should really try to avoid sleeping
there...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
