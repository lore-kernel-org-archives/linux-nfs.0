From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: Possible bugs in nfs-utils
Date: Fri, 23 Jun 2006 14:16:50 +1000
Message-ID: <1151036210.20487.514.camel@hole.melbourne.sgi.com>
References: <20060619203025.GA7102@us.ibm.com>
	<1150963520.20487.511.camel@hole.melbourne.sgi.com>
	<17562.23142.2509.874143@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Michael Halcrow <mhalcrow@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ftd6P-0008Vt-6o
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 21:17:05 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ftd6O-0004ng-54
	for nfs@lists.sourceforge.net; Thu, 22 Jun 2006 21:17:05 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17562.23142.2509.874143@cse.unsw.edu.au>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-06-22 at 18:52, Neil Brown wrote:
> On Thursday June 22, gnb@melbourne.sgi.com wrote:
> > On Tue, 2006-06-20 at 06:30, Michael Halcrow wrote:
> > > I ran nfs-utils through the Coverity source code scanner, and the
> > > following items were flagged that I thought might merit a second
> > > glance (source from util-linux-2.13-pre7.tar.bz2). Those with a more
> > > intimate knowledge of the code base can probably help out in
> > > determining whether some of these really are problematic:
> > 
> > Some of these look worth fixing.  Neil, I have a bunch of
> > trivial nfs-utils compile warnings fixes waiting to be
> > pushed, shall I add these in too?
> 
> Yeh, send 'em on down.
> Or if you happen to have them in a .git somewhere

I do, but not publicly available yet.  I can probably
have something up on oss.sgi.com in a few days.

> I could pull from
> that.  I haven't done a real 'git pull' yet and would like an excuse
> to experiment with it.

Sounds like fun.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.



Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
