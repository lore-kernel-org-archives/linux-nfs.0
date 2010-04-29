Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53910 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754480Ab0D3Va7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 17:30:59 -0400
Date: Thu, 29 Apr 2010 13:39:03 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Eshel <eshel@almaden.ibm.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
Subject: Re: [pnfs] Linux pNFS status meeting 04/29
Message-ID: <20100429173902.GE1654@fieldses.org>
References: <OF9FD7A126.8253DE0C-ON88257714.00106772-88257714.00108527@us.ibm.com> <20100429144600.GA1654@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100429144600.GA1654@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

1. upstream status/merge plans (trond, bfields)
	- 2.6.34-rc5
	- server: merged one 2.6.34 bugfix, some more bugfixes/cleanup for
	  2.6.35, no new features merged.
	- client: bunch of bugfixes:
		- writeback code fixes:	
			- race with commit
			- nfs_setup_writeback BUG_ON()
		- other than that, misc. NULL/ERR-mixups.
		- Andy notes he's been seeing bigfile blocked for >= 30
		  seconds; Trond says that's probably due to the commit
		  race above.

2. State of pNFS tree (bhalevy)
	- forwarded-ported to -rc5, released a few minutes ago.  Passes
	  cthon cleanly (thanks to commit race fix).
	- merged some other patches.

3. Mailing list change
	- consolidated pnfs and nfsv4 lists to linux-nfs@vger.kernel.org
	- kernel.org appears to be having trouble; bfields will
	  investigate.

4. Client
	4.1. Client pNFS status
		- Andros sent a bunch of patches that remove
		  non-file-layout stuff from initial submission and add
		  it back in later (but using the generic deviceid
		  cache); latter needs review from object and block
		  developers.
	4.2. Client state management design documentation (trond)
		- nothing to report

5. Server
	5.1. Todo's for minimal 4.1 server (bfields)
		http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues
		- made some updates; things I'm working on are marked.
		  (Note to self: needs some more updates.  Also, I'll
		  need to start moving "done" things into "needs
		  testing" category.
		- testing problems:
			- will probably need pynfs tests to go with
			  server 4.1 changes.
			- 4.1 pynfs doesn't handle DELAY errors, so they
			  fail immediately against current server.  Fred
			  will check if it's easily fixed.
			  I will also make Neil's deferral fix a higher
			  priority to remove need for so many
			  DELAY's.
	5.2. pnfs
		- Sorin notes he's been able to get block server up and
		  running (not bug-free, but it does some IO at least).
		  Hasn't worked out why Jiri Kortus isn't getting that
		  far.

6. Red Hat status
	- Steve will update to latest tag.
	- note to Steve: make sure avoiding commit race.  rc1-rc4-based
	  code had it, latest -rc5 tag should be OK.  Not sure about
	  2.6.33-based code.
	- Documentation:
		- Steve is finding documentation of pnfs setup hard to
		  find.  He will work on tracking down docs and
		  reorganizing wiki.
		- Andy will help Steve with GFS2 setup docs.
		- Sorin & co. should be able to help with block setup
		  docs.
	- Steved eventually wants to do more 4.1 testing.
	- Boaz asked for some pointers on how to get started building
	  rpm's, so he can distribute exofs utilities.  Steved will
	  help.

7. bakeathon plans
	- Summer in Ann Arbor
	- Fall in Boston?:
		- deciding on date.

8. Next meeting:
	- Same time, some place; Marc will be out, so Dean will host.

--b.
