From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Linux pNFS status meeting 06/03
Date: Sun, 6 Jun 2010 10:34:39 -0400
Message-ID: <20100606143439.GB6912@fieldses.org>
References: <OFD9CC398A.6555CB30-ON88257736.006D4B55-88257736.006D71E6@us.ibm.com> <20100603172210.GG24994@fieldses.org> <4C0B8259.6090500@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41234 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756570Ab0FFOek (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 6 Jun 2010 10:34:40 -0400
In-Reply-To: <4C0B8259.6090500@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 06, 2010 at 02:11:21PM +0300, Benny Halevy wrote:
> On Jun. 03, 2010, 20:22 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > On Wed, Jun 02, 2010 at 12:55:33PM -0700, Marc Eshel wrote:
> >> Meeting on Thursday 06/03/10 at 9:30 AM pacific time (12:30 PM UMICH time)
> > 
> > Rough notes (more distracted than usual, apologies):
> > 
> > 
> > Rough agenda.  Note Benny and Boaz will miss this one:
> 
> Actually, not this one (prob. cut'n'pase typo?)
> [And correcting mailing list on the Cc]

Yes.  Thanks for the corrections!

--b.

> 
> Benny
> 
> > 
> > 1. upstream status/merge plans (trond, bfields)
> > 	- 2.6.34 released, 2.6.35 merge window come and gone, 
> > 	- That means 2.6.35 is now for (certain) bug fixes only, new
> > 	  development will be queued for 2.6.36.
> > 	- I've started a for-2.6.36 branch for the server, just small
> > 	  bugfixes so far.
> > 	- (Trond absent).
> > 
> > 2. State of pNFS tree (bhalevy)
> > 	- new 2.6.34 and 2.6.33 versions released.  Hoping to leave
> > 	  2.6.33 only now.
> > 
> > 3. Client
> > 	3.1. Client pNFS status
> > 		- (missed some.)
> > 		- Andy working on reboot recovery?
> > 		- Boaz: what testing at bthon?
> > 			- Andy: forgetful model
> > 			- Boaz: Note that would require changes to object
> > 			  (and block?) server implementations. (Changes to
> > 			  generic server may be required, e.g. to handle
> > 			  DELAY on layout recall callback?)
> > 	3.2. Client state management design documentation (trond)
> > 		- (Trond absent)
> > 4. Server
> > 	4.1. Todo's for minimal 4.1 server (bfields)
> > 		- have 4.1 pynfs running against linux server, ironing
> > 		  out some problems; our local pynfs changes here:
> > 		  git://linux-nfs.org/~bfields/pynfs41.git
> > 		  (Main problem now is a SERVERFAULT error that prevents
> > 		  running all tests at once.  Another resource
> > 		  accounting bug, maybe?)
> > 		- contemplating porting pynfs server reboot recovery
> > 		  tests from 4.0 pynfs to 4.1 pynfs.
> > 		- hoping to start writing new server 4.1 tests over
> > 		  the next couple weeks.
> > 	4.2. pnfs
> > 		pnfs/gfs2:
> > 		- running basic pnfs/gfs2 performance tests.  Results
> > 		  don't show expected scaling.  Backend appears OK
> > 		  (tested by reading 3 different files from each of 3
> > 		  different gfs2 nodes).  Perhaps gfs2 isn't scaling
> > 		  reads to shared files as expected; test that
> > 		  hypothesis by
> > 		  	a) simultaneous reads from shared files over
> > 			gfs2 (without pnfs in the way)
> > 			b) modifying pnfs/gfs2 to work around the
> > 			problem by handing out single-DS layouts
> > 			(instead of striping).
> > 		- sent in a couple gfs2 patches.  Note one was an
> > 		  "obvious" fix, but may have broken stuff (e.g.
> > 		  getdeviceinfo) that depended on previous buggy
> > 		  behavior?  Will test.
> > 		exofs:
> > 		- Boaz working on results; plans to report in next week
> > 		  or so.
> > 
> > 5. redhat status (steved)
> > 	- continuing to backport client and server code 
> > 	- should have result at bakeathon.
> > 6. bakeathon plans
> > 	- ann arbor: Heard from everyone I expect but EMC.  I'll try to get
> > 	  out some logistical information next week.
> > 	- boston (Sorin working on hotel information?)
> > 		- (Sorin absent?)
> > 7. new business
> > 8. next meeting
> > 	- next thursday as usual.  (Probably skip thursday after next.)
> > 
> > --b.
> > _______________________________________________
> > NOTE: THIS LIST IS DEPRECATED.  Please use linux-nfs@vger.kernel.org instead.
> > (To subscribe to linux-nfs@vger.kernel.org: send "subscribe linux-nfs" in the body of a message to majordomo-u79uwXL29TaiAVqoAR/hOA@public.gmane.org)
> > 
> > NFSv4 mailing list
> > NFSv4@linux-nfs.org
> > http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
