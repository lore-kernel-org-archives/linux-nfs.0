From: "Rex Dieter" <rdieter@math.unl.edu>
Subject: Re: RH 7.3 kernels and NFS performance
Date: Thu, 8 Aug 2002 06:56:12 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208080656.12664.rdieter@math.unl.edu>
References: <Pine.LNX.4.44.0208080106550.16997-100000@opus.phy.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mathstat.unl.edu ([129.93.48.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17clts-0003lx-00
	for <nfs@lists.sourceforge.net>; Thu, 08 Aug 2002 04:56:20 -0700
Received: from duran.unl.edu (IDENT:U8uQSKsnpPJk5MxA8zH4hnY6/DA6d1As@duran.unl.edu [129.93.50.93])
	by mathstat.unl.edu (8.9.3/8.9.3) with ESMTP id GAA28423
	for <nfs@lists.sourceforge.net>; Thu, 8 Aug 2002 06:56:13 -0500
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


----- Original Message -----
From: "Seth Vidal" <skvidal@phy.duke.edu>

> > I just tested things with a test kernel (2.4.18-7) from redhat, and i=
t
> > sync write speeds were again way up there.  Problem fixed, as far as =
I'm
> > concerned... hopefully, they'll release an errata soon.
>
> look carefully - the only patches in  2.4.18-X (where X >5) are to misc
> network drivers. 2.4.18-5 with some network cards (specifically eepros =
and
> 3c905s) were terribly slow. 2.4.18-5e+ fix it.

I didn't look carefully, and it's changelog didn't reveal anything, but I=
=20
can tell you that I HAD tried kernel-2.4.18-5e, and the problem persisted=
=2E =20
As of 2.4.18-7, the problem is gone.  I may have to take a closer look=20
now... I'm curious.

-- Rex






-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
