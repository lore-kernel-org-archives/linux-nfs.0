From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Linux pNFS status meeting  5/06/10
Date: Thu, 6 May 2010 13:33:44 -0400
Message-ID: <20100506173344.GQ28399@fieldses.org>
References: <4BE1A15E.5030907@gmail.com> <20100505200524.GF14703@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pnfs mailing list <pnfs@linux-nfs.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44316 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756327Ab0EFRdq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 May 2010 13:33:46 -0400
In-Reply-To: <20100505200524.GF14703@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 05, 2010 at 04:05:24PM -0400, bfields wrote:
> On Wed, May 05, 2010 at 09:48:30AM -0700, Dean Hildebrand wrote:
> > Meeting on Thursday 5/06/2010 at 9:30 AM PDT (12:30 PM EST).
> 
> Rough agenda:
> 
> 1. upstream status/merge plans (trond, bfields)

	- Linus is at -rc6
	- Nothing new merged on server side
	- On client side:
		- work (not yet queued) fixing rpc auth cache shrinker
		- queued up delegation rcu bugfixes
		- considering doing something about state manager
		  resource deadlock that seems possible since it does
		  GFP_KERNEL allocations, and writes may be waiting on
		  it.  (bfields asks: what about gssd?  trond says: it
		  may have the same problem, but may be hard or
		  impossible to fix completely, and doesn't affect
		  everybody.)

> 2. State of pNFS tree (bhalevy)

	- Merged latest patchsets from Andy & Fred into his private tree
	  (generic deviceid-patches, and patches that prune the
	  to-submit stuff).

	- Hoping to send out some additional api cleanup patches.

> 3. Mailing list change

	- Unfortunately, vger.kernel.org went down just as I announced
	  the change, and stayed down a day or two.  So if you tried to
	  subscribe, it may not have worked.
	- If you had trouble: please try again, then let us know if
	  you're still having problems.

> 
> 4. Client
> 	4.1. Client pNFS status

		- Fred had questions for Benny & Boaz on objects-layout
		  requirements.  (Missed the details, sorry.)

> 	4.2. Client state management design documentation (trond)

		- Trond has started work on it.

> 5. Server
> 	5.1. Todo's for minimal 4.1 server (bfields)
> 		http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues
		- Benny has submitted patches to fix server-side
		  client-refcounting to eliminate some possible races in
		  4.1 case and start shrinking the scope of the state
		  lock.  bfields needs to review them.

> 		- pynfs testing
> 			- ERR_DELAY handling (iisaman)
				- nothing to report.
> 			- deferral fixes (bfields)
				- nothing to report.
			- A couple new citi students are starting work
			  on pynfs, so they may be able to take over
			  some of this.

> 	5.2. pnfs
> 		- Jiri Kortus's testing?
		- nothing to report.
> 
> 6. documentation
> 	- wiki organization, collect pnfs setup howto's (steved)
		- steved found what's needed is already there; he
		  rearranged things to hopefully make them easier to
		  find.
		(XXX: URL?)

> 
> 7. redhat status (steved)
	- working on pnfs rpm's.
	- Do we need a pnfs nfs-utils?  Not worth it for spnfs.  What
	  about "pnfs" export option?  Steved will collect patch adding
	  that into separate pnfs git branch, and we'll discuss whether
	  it makes sense to add to mainline nfs-utils.

> 
> 8. bakeathon plans
> 	- Summer in Ann Arbor
		- Progressine fine; thanks to those who have sent in
		  registration info; if you haven't already, please mail
		  bfields.
		- Note also if you're bringing more than 2 laptops per
		  person, or a laptop and a desktop: let me know.
> 	- Fall in Boston
		- Date chosen; Sorin working on the final details; should
		  have them out in the next week or so.

> 9. new business
> 
> 10. next meeting

	- same time, same place next week.

--b.
