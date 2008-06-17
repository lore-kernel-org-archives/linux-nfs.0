From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 2/5] rpc: Use separate spinlock for cred locking in
	auth_gss.c
Date: Tue, 17 Jun 2008 16:51:59 -0400
Message-ID: <20080617205159.GA5387@fieldses.org>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu> <1213397442-15611-2-git-send-email-bfields@citi.umich.edu> <1213397442-15611-3-git-send-email-bfields@citi.umich.edu> <1213459135.7149.7.camel@localhost> <20080614174528.GF27041@fieldses.org> <1213467387.7149.30.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:56481 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754942AbYFQUwB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2008 16:52:01 -0400
In-Reply-To: <1213467387.7149.30.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 14, 2008 at 02:16:27PM -0400, Trond Myklebust wrote:
> On Sat, 2008-06-14 at 13:45 -0400, J. Bruce Fields wrote:
> > > NACK. I deliberately ripped out the old struct gss_auth spinlock in
> > > order to allow multiple gss_auth per inode (I believe Kevin was asking
> > > for this).
> > 
> > OK, makes sense.  So what will be the scope of a cred lookup--an rpc
> > client?
> 
> That should normally be the case, but why do you need to change the
> locking here in the first place? Is there ever going to be a case where
> the same rpc_cred has upcalls on several different pipes? I can't see
> how that could be justified.

If you allow changing the upcall version over the life of the kernel,
then it's difficult to avoid.  You can insist that noone have both the
new and old version opened simultaneously, for example, but it's harder
to know when there are no longer messages sitting around that have been
unhashed but are still lying around waiting for a process to wake up and
examine their results.

--b.
