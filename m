From: Phy Prabab <phyprabab@yahoo.com>
Subject: Re: Strange delays on NFS server
Date: Wed, 11 Aug 2004 09:53:18 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040811165318.12636.qmail@web51807.mail.yahoo.com>
References: <20040811164135.GA11101@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BuwLs-0002ay-R5
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 09:53:24 -0700
Received: from web51807.mail.yahoo.com ([206.190.38.238])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.34)
	id 1BuwLs-0002hC-Bd
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 09:53:24 -0700
To: Olaf Kirch <okir@suse.de>, Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: <20040811164135.GA11101@suse.de>
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

Is it possible to get the patch to test it out?  I am
having some issues that are similar and would like to
see if your patch helps.

Thanks!
Phy

--- Olaf Kirch <okir@suse.de> wrote:

> On Wed, Aug 11, 2004 at 05:08:45PM +0100, Ian
> Thurlbeck wrote:
> > OK, I've been running "top -d 1 -i" and trying to
> see what comes up when
> > the server freezes. I caught one instance where a
> delay coincided
> > with about 15 nfsd + 1 kjournald process appearing
> in the top
> > display. I'm simultaneously looking at a graphical
> network tool to try
> > and see the traffic going to the server - anyone
> got a better suggestion?
> 
> This sounds exactly like the COMMIT stall problem
> for which I submitted
> the early-writeout patch to this list about a week
> ago.
> 
> I've been thinking about this a little more. It may
> be that one reason
> the problem is more pronounced in in 2.6 than in 2.4
> is the new io
> barrier code. In 2.6 ext3 uses barriers by default;
> Suse's 2.6 has reiserfs
> patches that add barriers (and enables them by
> default). We've reports of
> this problem on both file systems.
> 
> JFS does i/o barriers while XFS does not; and this
> also fits the pattern
> of what Ian reports. I dimly remember there's a
> kernel command line
> option to turn off barriers at the block io level.
> Can you try if
> that helps, Ian?
> 
> The more I think about this, the more I believe the
> early-writeout patch
> is the right way to address this problem (short of
> turning off barriers).
> When data hits the NFS server, it is supposed to go
> to disk rather
> soonishly. This also covers most of the rewrite
> case, at least as long
> as you have just one application writing to the file
> - all rewriting
> happens in the client cache.
> 
> The crucial question is, what is a good heursitic to
> choose when to
> initiate a write-out. Sequential writes to the end
> of file are easy
> enough to detect.
> 
> I have a somewhat updated version of my patch that
> covers just this
> case, and exports a sysctl to let you tune how often
> it initiates
> an early write-out.
> 
> Olaf
> -- 
> Olaf Kirch     |  The Hardware Gods hate me.
> okir@suse.de   |
> ---------------+ 
> 
> 
>
-------------------------------------------------------
> SF.Net email is sponsored by Shop4tech.com-Lowest
> price on Blank Media
> 100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R
> for only $33
> Save 50% off Retail on Ink & Toner - Free Shipping
> and Free Gift.
>
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 


__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
