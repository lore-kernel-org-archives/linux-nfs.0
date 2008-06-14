From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/5] rpc: Use separate spinlock for cred locking in
	auth_gss.c
Date: Sat, 14 Jun 2008 13:45:28 -0400
Message-ID: <20080614174528.GF27041@fieldses.org>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu> <1213397442-15611-2-git-send-email-bfields@citi.umich.edu> <1213397442-15611-3-git-send-email-bfields@citi.umich.edu> <1213459135.7149.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:35450 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752649AbYFNRpa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Jun 2008 13:45:30 -0400
In-Reply-To: <1213459135.7149.7.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 14, 2008 at 11:58:55AM -0400, Trond Myklebust wrote:
> On Fri, 2008-06-13 at 18:50 -0400, J. Bruce Fields wrote:
> > The i_lock uses in auth_gss.c are to protect the gc_upcall and gc_ctx
> > fields of the gss cred; so we can use a separate per-auth spinlock for
> > those instead of the i_lock.  This simplifies the locking in the case
> > where we have two different pipes (one the current pipe, one the pipe
> > for a new more flexible upcall), either of which might be used for gss
> > upcalls.
> 
> NACK. I deliberately ripped out the old struct gss_auth spinlock in
> order to allow multiple gss_auth per inode (I believe Kevin was asking
> for this).

OK, makes sense.  So what will be the scope of a cred lookup--an rpc
client?

I wish I had a better picture of what the data structures here will
eventually look like.

--b.
