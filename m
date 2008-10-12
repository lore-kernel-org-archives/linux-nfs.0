From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Mon, 13 Oct 2008 10:15:30 +1100
Message-ID: <18674.34066.316972.695627@notabene.brown>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net>
	<20081004213625.GA3709@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48943 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754032AbYJLXPp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Oct 2008 19:15:45 -0400
In-Reply-To: message from J. Bruce Fields on Saturday October 4
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Saturday October 4, bfields@fieldses.org wrote:
> On Fri, Oct 03, 2008 at 05:15:14PM -0400, Chuck Lever wrote:
> > Hi Bruce, Neil-
> > 
> > Here's my initial proposal to address the NFSv2/v3 lock recovery issue 
> > that results from having no UDP lockd listener.
> > 
> > Comments?  Did I miss anything?
> 
> Looks fine; I can't see any problem.  So I've applied to for-2.6.28.
> (An ack from Neil would be reassuring, though, if he gets a chance.)

Sorry for my tardiness.  September was a very hectic month for me.

One consequence of this change is that lockd always listens on TCP
even if NFSD and NFS are only using UDP.
Do we care?  I suspect not.

An alternative fix to the problem would be to always listen on UDP and
only listen on TCP if it was requested.  This would probably be a
smaller code change, and might in some sense be more flexible.

Will we ever want to talk NLM over any other protocol? RDMA?
Is UDP6 a different protocol in this context?  I suspect not.

I guess I have a small leaning towards just always listening on UDP
and leaving everything else the same, but it is small, not strong.  So
unless either of you lean the same way I'm happy to give my

 Acked-By: NeilBrown <neilb@suse.de>

to the current patches.

Thanks,
NeilBrown
