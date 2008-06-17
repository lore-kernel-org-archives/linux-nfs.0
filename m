From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/5] rpc: Use separate spinlock for cred locking in
	auth_gss.c
Date: Tue, 17 Jun 2008 17:34:47 -0400
Message-ID: <1213738487.7288.66.camel@localhost>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
	 <1213459135.7149.7.camel@localhost> <20080614174528.GF27041@fieldses.org>
	 <1213467387.7149.30.camel@localhost>  <20080617205159.GA5387@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:44392 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756846AbYFQVfk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Jun 2008 17:35:40 -0400
In-Reply-To: <20080617205159.GA5387@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2008-06-17 at 16:51 -0400, J. Bruce Fields wrote:
> On Sat, Jun 14, 2008 at 02:16:27PM -0400, Trond Myklebust wrote:
> > On Sat, 2008-06-14 at 13:45 -0400, J. Bruce Fields wrote:
> > > > NACK. I deliberately ripped out the old struct gss_auth spinlock in
> > > > order to allow multiple gss_auth per inode (I believe Kevin was asking
> > > > for this).
> > > 
> > > OK, makes sense.  So what will be the scope of a cred lookup--an rpc
> > > client?
> > 
> > That should normally be the case, but why do you need to change the
> > locking here in the first place? Is there ever going to be a case where
> > the same rpc_cred has upcalls on several different pipes? I can't see
> > how that could be justified.
> 
> If you allow changing the upcall version over the life of the kernel,
> then it's difficult to avoid.  You can insist that noone have both the
> new and old version opened simultaneously, for example, but it's harder
> to know when there are no longer messages sitting around that have been
> unhashed but are still lying around waiting for a process to wake up and
> examine their results.

AFAIK, there are two cases when the dying rpc.gssd closes the pipe:

     1. gss_cred->gc_upcall is set. In this case, the gss_cred has a
        full reference to the gss_msg, so it has no trouble locating the
        message and figuring out if it needs to resend (rpc_purge_list()
        will ensure that the error field is set to EAGAIN) or if the
        call completed before gssd died. If you are worried about the
        fact that gss_upcall_callback uses gss_msg->auth to access the
        inode in order to do the locking, then just add a pointer to the
        inode to gss_msg: it is not as if a gss_msg can migrate from one
        upcall queue to another.
     2. gss_cred->gc_upcall is not set. In this case the call to
        rpc_purge_list() in rpc_pipe_release() will ensure that the
        message gets immediately released.

In other words, I can't see that keeping the current behaviour will
cause you to have more than one upcall at a time even if you do restart
rpc.gssd.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
