From: "Lever, Charles" <cel@netapp.com>
Subject: RE: NFSv3 ACL status?
Date: Thu, 12 Aug 2004 07:03:14 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07DC0@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <acl-devel@bestbits.at>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvGB1-0000cV-17
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 07:03:31 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BvGB0-0001tx-NI
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 07:03:30 -0700
To: "Peter Astrand" <peter@cendio.se>
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

> Can someone give an quick overview of the Linux NFSv3 ACL=20
> status? The Linux NFS FAQ at http://nfs.sourceforge.net/ says:
>=20
> "D3. What does this mean:  svc: unknown program 100227 (me 100003)
>=20
> A. It refers to a mount request by a Solaris system that is=20
> trying to get ACL information - which linux obviously does not have. "
>=20
> But: http://acl.bestbits.at/ seems to indicate that ACLs over=20
> NFSv3 actually works, and provides patches for 2.6.1, but I=20
> can't find any information about if this patch is really=20
> needed for modern kernels
> (2.6.7) or modern distributions. Is this patch for the=20
> server, client or=20
> both?=20

Solaris ACL support is in some kernels but not others.  i believe RHEL
3.0 includes Solaris ACL support for both the NFS client and server, for
example, as an extra patch.  stock 2.4 does not.

i believe there is a plan to include Solaris NFSv3 ACL support in the
2.6 client and server at some point in the near future so that everyone
will get the same implementation, and the distributions won't have to
add a separate patch if they need it.

the Linux NFSv4 client/server implementation is getting ACL support
right now.  there are issues with how to map POSIX ACLs (which Linux
uses) to NFSv4 ACLs, which are semantically richer but not quite
compatible, and how to allow user-level programs to access and modify
NFSv4 ACLs directly.  but NFSv4 ACL support should be wire compatible
with Sun's Solaris NFSv4 implementation as well.

at some point when the universe is less complicated i plan to update the
FAQ to reflect these changes.  (thermodynamically i should not have long
to wait, right?)


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
