From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: PATCH - > 256 NFS mounts. Was: Re: Linux NFS FAQ updates
Date: Thu, 8 May 2003 08:20:50 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611312748D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19DnCg-0008Hb-00
	for <nfs@lists.sourceforge.net>; Thu, 08 May 2003 08:21:02 -0700
To: "Neil Brown" <neilb@cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

hi neil-

> On Thursday April 24, Charles.Lever@netapp.com wrote:
>=20
> >                       and question B3 discusses the
> > "255 NFS mounts per client" limitation.
>=20
> You could add something more to this section if you like....
>=20
> "It is possible to exceed the limit of 256 filesystems using=20
> <a href=3D"See Below">this</a> patch.  It utilised 3 more major =
numbers
> (which have been allocated by lanana) and so allows upto
> 1024 non-device mounts (such as NFS).

thanks for the patch.  we considered adding a paragraph
to this effect (there is a similar patch floating around
out there).  here's why i think it is not a good idea:

> This patch does <b>not</b> address issues of running out of=20
> privileged=20
> ports and so the effective limit is still well below 1024 ( but can be
> maximised by mixing UDP and TCP mounts)."

there are so many complicated little issues with how many
NFS mounts you can get on the client that the best solution
by far right now is to use an automounter.  we can recommend
using an automounter in most situations, especially cases
where a customer is required to stay on a commercially
distributed kernel like Red Hat Advanced Server 2.1 to
maintain some support contract.

IMHO, adding a couple of major numbers is just a band-aid.
most of that headroom will be eaten away by other anonymous
file systems that are now arriving on the scene.

additionally, most folks who want more than 250 mounts on
a client really want thousands of mounts, and this patch
won't achieve that.  deployments like that must use an
automounter anyway.

so i think the right thing to do is recommend using
an automounter; it's a good generic solution for now.
we can look to the development kernels to figure out
how to eliminate this limitation entirely.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
