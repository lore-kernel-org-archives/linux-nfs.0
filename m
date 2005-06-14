From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS crash on Suse, any ideas on which normal nfs patch could be a cause/fix?
Date: Tue, 14 Jun 2005 13:06:14 +0200
Message-ID: <20050614110614.GH5155@suse.de>
References: <20050610075637.GB5534@suse.de> <EXCHG2003xf4yp8ARf30000046f@EXCHG2003.microtech-ks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Di9FT-0001dI-Ti
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 04:06:27 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Di9FT-00089C-5x
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 04:06:27 -0700
To: Roger Heflin <rheflin@atipa.com>
In-Reply-To: <EXCHG2003xf4yp8ARf30000046f@EXCHG2003.microtech-ks.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Andi Kleen mentioned that this may be a BIOS or driver problem.
Drivers accessing incorrect memory mappings may cause a watchdog to
trigger, which will elicit an MCE.

The address is just over 2GB; the BIOS may have created the
memory hole there. Can you disable memory remapping in the
BIOS?

Olaf


On Fri, Jun 10, 2005 at 03:53:14PM -0500, Roger Heflin wrote:
> We have looked at this more carefully, the customer has
> got me more information and details.   It looks like some
> way nfs exercises a network bug and causes the network driver
> to crash.    The machine/os has survived a full kickstart
> (with a several hundred MB install by 100 plus identical
> machines without that exercising the bug) and a quite a
> bit of light nfs usage, but heavier nfs usage, including
> using bonnie will make the machines fall over fairly quick.
> 
> We are checking for what sort of issues there could be with
> the network driver/network firmware/bmc card.   
> 
> For information this is a Quad Tyan 4882 with 32GB of ram
> (16 have 64GB of ram) with the customer having over 100
> of the Quads.
> 
> There is also a large number of duals, but after further
> examination we don't believe those have the issue.
> 
>                          Roger
> 
> > -----Original Message-----
> > From: Olaf Kirch [mailto:okir@suse.de] 
> > Sent: Friday, June 10, 2005 2:57 AM
> > To: Roger Heflin
> > Cc: nfs@lists.sourceforge.net
> > Subject: Re: [NFS] NFS crash on Suse, any ideas on which 
> > normal nfs patch could be a cause/fix?
> > 
> > On Thu, Jun 09, 2005 at 01:50:13PM -0500, Roger Heflin wrote:
> > > The kernel crash message was:
> > > 
> > > CPU 0: Machine Check Exception:          4 Bank 4: f60da00100000813
> > >   RIP !INEXACT!  10:<ffffffff8022fae2> {copy_user_generic_c0x8/0x26}
> > >   TSC 3d101af6bf756 ADDR 4304010
> > >   Kernel panic: Machine check
> > 
> > This is not an NFS bug, it's a machine check exception. Your 
> > machines have bad RAM it seems.
> > 
> > Olaf
> > -- 
> > Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
> > okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> > 
> 
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
> a projector? How fast can you ride your desk chair down the office luge track?
> If you want to score the big prize, get to know the little guy.  
> Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
