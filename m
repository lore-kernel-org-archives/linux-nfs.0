From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: NFS crash on Suse, any ideas on which normal nfs patch could be a cause/fix?
Date: Fri, 10 Jun 2005 08:15:08 -0500
Message-ID: <EXCHG2003PNXRPmcarc00000406@EXCHG2003.microtech-ks.com>
References: <20050610075637.GB5534@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DgjKq-0001w5-TX
	for nfs@lists.sourceforge.net; Fri, 10 Jun 2005 06:14:08 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DgjKo-0003uz-1k
	for nfs@lists.sourceforge.net; Fri, 10 Jun 2005 06:14:07 -0700
To: "'Olaf Kirch'" <okir@suse.de>
In-Reply-To: <20050610075637.GB5534@suse.de>
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


The other three don't do this, so there may just be something
about this machine that is otherwise wrong, so this error may
not be from this problem, though it is odd given that the machine
does not exhibit this message with any other tests.

We know what bad ram/bad cpu looks like, the machines all have ECC,
and are getting no ecc errors, and they pass several days of running
a intensive memory/cpu program with no ecc errors, no crashes outside
of using NFS.

We also have never seen a MCE with a actual kernel routine listed
off to the side like that, and we have seen at least 100+ MCE's of
other sorts, and have fixed them by replacing ram or cpus.

                               Roger 

> -----Original Message-----
> From: Olaf Kirch [mailto:okir@suse.de] 
> Sent: Friday, June 10, 2005 2:57 AM
> To: Roger Heflin
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS crash on Suse, any ideas on which 
> normal nfs patch could be a cause/fix?
> 
> On Thu, Jun 09, 2005 at 01:50:13PM -0500, Roger Heflin wrote:
> > The kernel crash message was:
> > 
> > CPU 0: Machine Check Exception:          4 Bank 4: f60da00100000813
> >   RIP !INEXACT!  10:<ffffffff8022fae2> {copy_user_generic_c0x8/0x26}
> >   TSC 3d101af6bf756 ADDR 4304010
> >   Kernel panic: Machine check
> 
> This is not an NFS bug, it's a machine check exception. Your 
> machines have bad RAM it seems.
> 
> Olaf
> -- 
> Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
> okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax
> 



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
