From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: Random ESTALE due to lookup "/" in mount point?
Date: Fri, 25 Aug 2006 01:19:54 +0200
Message-ID: <20060824231954.GA27030@janus>
References: <20060823150941.GA13000@janus> <1156350025.5619.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GGOUS-0002m1-2f
	for nfs@lists.sourceforge.net; Thu, 24 Aug 2006 16:20:00 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GGOUQ-0004ll-91
	for nfs@lists.sourceforge.net; Thu, 24 Aug 2006 16:20:00 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1156350025.5619.14.camel@localhost>
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

On Wed, Aug 23, 2006 at 12:20:25PM -0400, Trond Myklebust wrote:
> On Wed, 2006-08-23 at 17:09 +0200, Frank van Maarseveen wrote:
> > NFSv3, udp, client=2.6.17.8, server=tru64
> > 
> > On the client I started to get some random ESTALE errors which disappeared
> > quickly afterwards without a remount. The errors only occurred when typing
> > 
> > 	stat ..
> > 
> > in a subdirectory of a mountpoint. Doing ls -al in that subdirectory
> > gave an ESTALE only on "..". I could even change directory to / and back
> > without an ESTALE but the "stat .." command still gave an ESTALE.
> > 
> > A "tcpdump -i eth0 udp port 2049 -n -s 1500" showed something which is
> > unusual to my knowledge. The kernel tried to lookup "/" in the mount
> > point as it seems:
> 
> I've never seen that, and my own kernel certainly appears to do no such
> thing when I stat '..'.
> 
> Any chance of a 'strace' with that?

It's reproduceable now but it appears that there's a nonstandard kernel
patch from me involved to do a selective "noac" (www.frankvm.com/nfs-noac,
it's a bit hackish...).  I think this results in an incorrect revalidation
of the mount point and I guess "/" is coming from the dcache: the fake
name of any root inode IIRC.

In short, I have to sort it out but it's probably only my patch at
fault. Sorry for the disturbance.

-- 
Frank

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
