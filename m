Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55070 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757867Ab0ERPMk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 May 2010 11:12:40 -0400
Date: Tue, 18 May 2010 11:12:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Eshel <eshel@almaden.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [pnfs] Linux pNFS status meeting 05/13
Message-ID: <20100518151239.GE17823@fieldses.org>
References: <OF0E51ED85.C973CB93-ON88257721.006B7902-88257721.006B9A2F@us.ibm.com> <20100512200801.GN6135@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100512200801.GN6135@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 12, 2010 at 04:08:01PM -0400, bfields wrote:
> On Wed, May 12, 2010 at 12:35:18PM -0700, Marc Eshel wrote:
> > Meeting on Thursday 05/13/10 at 9:30 AM pacific time (12:30 PM UMICH time)
> 
> Rough agenda:

Apologies, I've been busier than usual and forgot to send out my notes:

1. upstream status/merge plans (trond, bfields)
	- rc7 released
	- bfields: reclaim complete, benny's patches
	- Trond: cleaning up branches, merged 2.6.35 stuff in (stack
	  reduction, Chuck's rtc-resolution patches).  Haven't merged in
	  access & auth cache -shrinker changes.  Also: state-recovery
	  thread deadlock still being worked.  Rearranged rpc-task
	  structure fields to shrink struct size.  That done, will send
	  changelog to list.

2. State of pNFS tree (bhalevy)
	- [distracted, missed some notes]
	- note also cleaned up gfs2 branch

3. Mailing list change
	- no problems reported, except Benny getting repeatedly bounced
	  off?  He'll investigate farther.  No response from postmaster.

4. Client
	4.1. Client pNFS status
		- stable/unstable write-discussion.
		- Andy notes: usually tests with writes to gfs2 turned
		  on, even though not really optimal (and will stay turned
		  off in mainstream).
		- Benny: working on some io path bugs; will discuss on
		  mailing list bugs.  Ricardo: note Fred may be working
		  on same area.  (E.g.: on "done" path, two closes (one
		  of layout_commit context, one layout return on close
		  path?) were racing with each other?  Looks like there
		  may be patches that fix that.  Also saw stable
		  object-layout write problems.)
		- Alexandros doing some work on layout-management, close
		  to sending.
		- what about ipv6?: reports are that it's work; not sure
		  anyone's been thinking about it hard, though.
		  (What about device cache?  Andy should take a look.
		  What about gfs2 data server references?  Ricardo says
		  this was all "priority B" on client.)
	4.2. Client state management design documentation (trond)
		- some progress last week, none this.
5. Server
	5.1. Todo's for minimal 4.1 server (bfields)
		- Benny's patches
		- pynfs testing
	5.2. pnfs
		- question about exports.
		- exofs; did some testing, no report yet (distracted by
		  some bugs)

6. redhat status (steved)
	- nothing to report
7. bakeathon plans
	- ann arbor: going fine
	- boston: still waiting on hotel details.
8. new business
	- none
9. next meeting
	- same time (note Benny and Boaz expect to miss it).

--b.

