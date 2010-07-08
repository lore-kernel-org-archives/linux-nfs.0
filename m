From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Linux pNFS status meeting 07/08
Date: Thu, 8 Jul 2010 13:45:58 -0400
Message-ID: <20100708174558.GE19375@fieldses.org>
References: <OF60B406A7.E52268C8-ON8825775A.000C6BD9-8825775A.000C8A46@us.ibm.com>
 <20100708154802.GB19375@fieldses.org>
 <op.vfi7ssfcunckof@usensfaibisl2e.eng.emc.com>
 <20100708160637.GC19375@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marc Eshel <eshel@almaden.ibm.com>, linux-nfs@vger.kernel.org
To: sfaibish <sfaibish@emc.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40824 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756709Ab0GHRqH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jul 2010 13:46:07 -0400
In-Reply-To: <20100708160637.GC19375@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also I'd like to hand off running and taking notes on this meeting to
someone else for a while.  (Benny, maybe?)  Or we can go back to making
the meeting more informal if that's preferred.

--b.

1. upstream status/merge plans (trond, bfields)
	- upstream at 2.6.35-rc4.
	- server side: some bugfixes merged to callback code; allocation
	  failures changed to return DELAY.
	- discussion of error return on client callback-parsing error.
	- trond: everything from before bakeathon is in nfs-2.6.36
	  branch or upstream.  Also some file locking bugfixes
	  (bugzilla.kernel.org #14501).  Also sending release_lockowner
	  more often to keep server resources down.

2. State of pNFS tree (bhalevy)
	- working on patches from boaz and andy for release branch.
	  Anyone else have big pending patchsets?
		- Jim is getting complex-volume block patches tested,
		  will send them out soon.
		- Fred has some pending stuff ("minor cleanup")
	- next week would like to start cleaning up and squashing
	  together patches.  Also will truncate some of the history.

3. Client
	3.1. Client pNFS status
		- Andy needs to look at state reclaim stuff?
		- Andy still wondering what to do with the nfs inode
		  layout pointer.  What's the lifetime of the thing that
		  points to?
	3.2. Client state management design documentation (trond)
		- Also, on docs: Andy will check that wiki docs are
		  uptodate.  And will do some more documentation of
		  refcnts, as will Fred.

4. Server
	4.1. Todo's for minimal 4.1 server (bfields)
		- still working on callback changes.  Trond notes
		  ongoing rpc code improvements may allow us to do much
		  of this by keeping a single client and modifying its
		  transports, in which case I may be able to replace my
		  callbacks with single rpc tasks.
		- also fixing 4.0/4.1 bug that prevents exclusive locks
		  on upgraded open.
	4.2. pnfs
		- pnfs/gfs2
			- I'll ask Eric for a report on gfs2 bakeathon
			  testing.
		- exofs
			- I'll ask Brian about citi exofs setup status.

5. boston bakeathon
	- October 4-8.
	- Details are finalized, to be posted soon.
	- If your company will be bringing large equipment, let Sorin
	  know.
	- If anyone would be interested in sponsoring a reception or
	  other addition to the bakeathon, contact Sorin.  (Or if you
	  know who at your company would handle such a thing, let Sorin
	  know.)

6. new business
	- Sorin asked Trond for summary of layout-commit discussion.
	  Discussion ensued.

7. next meeting
	- next week as usual.
