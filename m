Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41980 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753064Ab0ETUY0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 May 2010 16:24:26 -0400
Date: Thu, 20 May 2010 16:24:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Marc Eshel <eshel@almaden.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [pnfs] Linux pNFS status meeting 05/20
Message-ID: <20100520202425.GB27395@fieldses.org>
References: <20100518223720.GY20706@fieldses.org> <20100518224016.GZ20706@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100518224016.GZ20706@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, May 18, 2010 at 06:40:17PM -0400, J. Bruce Fields wrote:
> Just noticed this got sent to the wrong list.  (Marc, these should go to
> linux-nfs@vger.kernel.org, probably not nfsv4@ietf.org.)
> 
> --b.
> 

With several core developers missing, this was extremely short.

> On Tue, May 18, 2010 at 06:37:20PM -0400, J. Bruce Fields wrote:
> > Rough agenda.  Note Benny and Boaz will miss this one:
> > 
> > 1. upstream status/merge plans (trond, bfields)

2.6.34 is released, the merge window for 2.6.35 is open, Linus has
merged both my changes and Trond's.

> > 2. State of pNFS tree (bhalevy--skip?)
> > 
> > 3. Client
> > 	3.1. Client pNFS status
> > 		- Benny was working on some io path bugs which he
> > 		  intended to discuss on mailing list.
> > 		- Alexandros was doing some work on layout-management, close
> > 		  to sending out.

Alexandros mailed out his work.

Fred also sent some patches this morning.

Andy has been working on layout-commit lockups using a gfs2 server
modified to allow writes and to claim all writes are stable.

> > 	3.2. Client state management design documentation (trond)
> > 4. Server
> > 	4.1. Todo's for minimal 4.1 server (bfields)

Have added some items to:
	http://wiki.linux-nfs.org/wiki/index.php/Server_4.0_and_4.1_issues

and moved some to "Done, needs testing" category.

Some citi students are debugging pynfs problems; initial patches sent to
Fred.  He'll take a look.

> > 	4.2. pnfs
> > 
> > 5. redhat status (steved)
> > 6. bakeathon plans
> > 	- ann arbor

CITI, Sun, Netapp, EMC, RedHat expected.  Attendance looks similar to
recent bakeathons so far.

> > 	- boston (Sorin working on hotel information?)
> > 8. new business
> > 9. next meeting

Same time next week.

--b.
