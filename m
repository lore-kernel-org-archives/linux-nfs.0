From: Norman Weathers <norman.r.weathers@conocophillips.com>
Subject: Re: Strange delays on NFS server
Date: Wed, 11 Aug 2004 14:42:13 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200408111442.13136.norman.r.weathers@conocophillips.com>
References: <4119FB15.7010205@stams.strath.ac.uk> <411A448D.3080205@stams.strath.ac.uk> <20040811164135.GA11101@suse.de>
Reply-To: norman.r.weathers@conocophillips.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: Olaf Kirch <okir@suse.de>, Ian Thurlbeck <ian@stams.strath.ac.uk>,
   Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Buz03-00078w-Gu
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 12:43:03 -0700
Received: from mailman1.ppco.com ([138.32.33.10])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Buz03-0004rX-3T
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 12:43:03 -0700
Received: from bvlextrd03.conoco.net (trend3.ppco.com [138.32.33.146])
	by mailman1.ppco.com (8.12.8/8.12.8) with ESMTP id i7BJh1O7009151
	for <nfs@lists.sourceforge.net>; Wed, 11 Aug 2004 14:43:01 -0500
To: nfs@lists.sourceforge.net
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


This would be probably what I am experiencing as well.  Using XFS on our NFS 
server (2.6.7 kernel, Fedora Core 2), we get exceptional numbers.  Using JFS, 
it stalls to the point of being unusable.  Does anyone know the kenrnel 
command line option that Olaf is mentioning?

On Wednesday 11 August 2004 11:41, Olaf Kirch wrote:
> On Wed, Aug 11, 2004 at 05:08:45PM +0100, Ian Thurlbeck wrote:
> > OK, I've been running "top -d 1 -i" and trying to see what comes up when
> > the server freezes. I caught one instance where a delay coincided
> > with about 15 nfsd + 1 kjournald process appearing in the top
> > display. I'm simultaneously looking at a graphical network tool to try
> > and see the traffic going to the server - anyone got a better suggestion?
>
> This sounds exactly like the COMMIT stall problem for which I submitted
> the early-writeout patch to this list about a week ago.
>
> I've been thinking about this a little more. It may be that one reason
> the problem is more pronounced in in 2.6 than in 2.4 is the new io
> barrier code. In 2.6 ext3 uses barriers by default; Suse's 2.6 has reiserfs
> patches that add barriers (and enables them by default). We've reports of
> this problem on both file systems.
>
> JFS does i/o barriers while XFS does not; and this also fits the pattern
> of what Ian reports. I dimly remember there's a kernel command line
> option to turn off barriers at the block io level. Can you try if
> that helps, Ian?
>
> The more I think about this, the more I believe the early-writeout patch
> is the right way to address this problem (short of turning off barriers).
> When data hits the NFS server, it is supposed to go to disk rather
> soonishly. This also covers most of the rewrite case, at least as long
> as you have just one application writing to the file - all rewriting
> happens in the client cache.
>
> The crucial question is, what is a good heursitic to choose when to
> initiate a write-out. Sequential writes to the end of file are easy
> enough to detect.
>
> I have a somewhat updated version of my patch that covers just this
> case, and exports a sysctl to let you tune how often it initiates
> an early write-out.
>
> Olaf

-- 

Norman Weathers
SIP Linux Cluster
TCE UNIX
ConocoPhillips
Houston, TX

Office:  LO2003
Phone:   ETN  639-2727
	 or (281) 293-2727


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
