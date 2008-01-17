From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 17 Jan 2008 15:23:42 -0500
Message-ID: <20080117202342.GA6416@fieldses.org>
References: <18315.62909.330258.83038@notabene.brown> <478D14C5.1000804@redhat.com> <18317.7319.443532.62244@notabene.brown> <478D3820.9080402@redhat.com> <20080117151007.GB16581@fieldses.org> <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org> <478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org> <478F9946.9010601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60258 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbYAQUXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2008 15:23:48 -0500
In-Reply-To: <478F9946.9010601@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To summarize a phone conversation from today:

On Thu, Jan 17, 2008 at 01:07:02PM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> Would there be any advantage to enforcing that requirement in the
>> server?  (For example, teaching nlm to reject any locking request for a
>> certain filesystem that wasn't sent to a certain server IP.)
>>
>> --b.
>>   
> It is doable... could be added into the "resume" patch that is currently  
> being tested (since the logic is so similar to the per-ip base grace  
> period) that should be out for review no later than next Monday.
>
> However, as any new code added into the system, there are trade-off(s).  
> I'm not sure we want to keep enhancing this too much though.

Sure.  And I don't want to make this terribly complicated.  The patch
looks good, and solves a clear problem.  That said, there are a few
related problems we'd like to solve:

	- We want to be able to move an export to a node with an already
	  active nfs server.  Currently that requires restarting all of
	  nfsd on the target node.  This is what I understand your next
	  patch fixes.
	- In the case of a filesystem that may be mounted from multiple
	  nodes at once, we need to make sure we're not leaving a window
	  allowing other applications to claim locks that nfs clients
	  haven't recovered yet.
	- Ideally we'd like this to be possible without making the
	  filesystem block all lock requests during a 90-second grace
	  period; instead it should only have to block those requests
	  that conflict with to-be-recovered locks.
	- All this should work for nfsv4, where we want to eventually
	  also allow migration of individual clients, and
	  client-initiated failover.

I absolutely don't want to delay solving this particular problem until
all the above is figured out, but I would like to be reasonably
confident that the new user-interface can be extended naturally to
handle the above cases; or at least that it won't unnecessarily
complicate their implementation.

I'll try to sketch an implementation of most of the above in the next
week.

Anyway, that together with the fact that 2.6.25 is opening up soon (in a
week or so?) inclines me toward delay submitting this until 2.6.26.

> Remember,  
> locking is about latency. Adding more checking will hurt latency.

Do you have any latency tests that we could use, or latency-sensitive
workloads that you use as benchmarks?

My suspicion is that checks such as these would be dwarfed by the posix
deadlock detection checks, not to mention the roundtrip to the server
for the nlm rpc and (in the gfs2 case) the communication with gfs2's
posix lock manager.

But I'd love any chance to demonstrate lock latency problems--I'm sure
there's good work to be done there.

--b.
