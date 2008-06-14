From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/5] rpc: Use separate spinlock for cred locking in
	auth_gss.c
Date: Sat, 14 Jun 2008 14:16:27 -0400
Message-ID: <1213467387.7149.30.camel@localhost>
References: <1213397442-15611-1-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-2-git-send-email-bfields@citi.umich.edu>
	 <1213397442-15611-3-git-send-email-bfields@citi.umich.edu>
	 <1213459135.7149.7.camel@localhost>  <20080614174528.GF27041@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: aglo@citi.umich.edu, kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41142 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753543AbYFNSko (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 14 Jun 2008 14:40:44 -0400
In-Reply-To: <20080614174528.GF27041@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 2008-06-14 at 13:45 -0400, J. Bruce Fields wrote:
> > NACK. I deliberately ripped out the old struct gss_auth spinlock in
> > order to allow multiple gss_auth per inode (I believe Kevin was asking
> > for this).
> 
> OK, makes sense.  So what will be the scope of a cred lookup--an rpc
> client?

That should normally be the case, but why do you need to change the
locking here in the first place? Is there ever going to be a case where
the same rpc_cred has upcalls on several different pipes? I can't see
how that could be justified.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
