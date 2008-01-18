From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Fri, 18 Jan 2008 11:03:08 +0100
Message-ID: <20080118100308.GA26106@janus>
References: <478D14C5.1000804@redhat.com> <18317.7319.443532.62244@notabene.brown> <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org> <478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org> <478F9946.9010601@redhat.com> <20080117202342.GA6416@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <wcheng@redhat.com>, Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:36741 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755008AbYARKDK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2008 05:03:10 -0500
In-Reply-To: <20080117202342.GA6416@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 17, 2008 at 03:23:42PM -0500, J. Bruce Fields wrote:
> To summarize a phone conversation from today:
> 
> On Thu, Jan 17, 2008 at 01:07:02PM -0500, Wendy Cheng wrote:
> > J. Bruce Fields wrote:
> >> Would there be any advantage to enforcing that requirement in the
> >> server?  (For example, teaching nlm to reject any locking request for a
> >> certain filesystem that wasn't sent to a certain server IP.)
> >>
> >> --b.
> >>   
> > It is doable... could be added into the "resume" patch that is currently  
> > being tested (since the logic is so similar to the per-ip base grace  
> > period) that should be out for review no later than next Monday.
> >
> > However, as any new code added into the system, there are trade-off(s).  
> > I'm not sure we want to keep enhancing this too much though.
> 
> Sure.  And I don't want to make this terribly complicated.  The patch
> looks good, and solves a clear problem.  That said, there are a few
> related problems we'd like to solve:
> 
> 	- We want to be able to move an export to a node with an already
> 	  active nfs server.  Currently that requires restarting all of
> 	  nfsd on the target node.  This is what I understand your next
> 	  patch fixes.

Maybe a silly question but what about using "exportfs -r" for this?

-- 
Frank
