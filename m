From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: add network test when host expire but hold lock
	at nlm_gc_hosts
Date: Wed, 2 Dec 2009 12:09:31 -0500
Message-ID: <20091202170931.GD13406@fieldses.org>
References: <4B163798.7010309@cn.fujitsu.com> <20091202072644.31c5d17e@tlielax.poochiereds.net> <1259764143.2663.10.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	Mi Jinlong <mijinlong@cn.fujitsu.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:57685 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754700AbZLBRIf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Dec 2009 12:08:35 -0500
In-Reply-To: <1259764143.2663.10.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 02, 2009 at 09:29:03AM -0500, Trond Myklebust wrote:
> On Wed, 2009-12-02 at 07:26 -0500, Jeff Layton wrote: 
> > On Wed, 02 Dec 2009 17:47:04 +0800
> > Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:
> > 
> > > After a client get lock, it's network partition for some reasons.
> > > other client cannot get lock success forever.
> > > 
> > > This patch can avoid this problem using rpc_ping to test client's
> > > network when host expired but hold lock.
> > > 
> > > If the client's network is partition, server will release client's 
> > > lock, other client will get lock success.
> > > 
> > > Signed-off-by: mijinlong@cn.fujitsu.com
> > 
> > Yikes! That sounds like it'll make locking subject to the reliability
> > of the network. I don't think that's a good idea.
> > 
> > What might be more reasonable is to consider implementing something
> > like the clear_locks command in Solaris. That is, a way for an admin to
> > remove server-side locks held by a client that he knows is never going
> > to come back. With that, this sort of thing at least becomes a willful
> > act...
> 
> Agreed on both counts.
> 
> We should not be changing the semantics of either NFSv3 or NLM at this
> time. That will break existing setups that are treating NFSv3 as being a
> stable platform.
> As I've said in previous correspondence: NFSv4 already offers lease
> based locking. If people are worried about network partitions and/or
> locks being held by clients that are dead, then they can switch to that.
> 
> On the other hand, a clear_locks command could be useful in order to
> tell a server that a given client is dead. It should be fairly easy to
> leverage the existing NSM/statd protocol to implement this.

Oh, so all clear_locks does is send an nsm notification?  Yeah, that
sounds like a completely reasonable project for someone.

--b.
