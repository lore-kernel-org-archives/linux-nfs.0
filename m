From: "Lever, Charles" <cel@netapp.com>
Subject: RE: NFSv3 ACL status?
Date: Thu, 12 Aug 2004 08:00:56 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07DC1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvH4k-0006pW-O9
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 08:01:06 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BvH4k-0001DR-Ci
	for nfs@lists.sourceforge.net; Thu, 12 Aug 2004 08:01:06 -0700
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

[ acl-devel@bestbits.at is rejecting my mail, so i have dropped it from
the cc: field ]

> > Solaris ACL support is in some kernels but not others.  i=20
> believe RHEL=20
> > 3.0 includes Solaris ACL support for both the NFS client=20
> and server,=20
> > for example, as an extra patch.  stock 2.4 does not.
>=20
> Now I'm confused. Is "Solaris ACL support" something=20
> different than the generic ACL patches Andreas provides?

Sun created a side-band NFS-related protocol (like NLM or NSM) to allow
NFS clients to access and modify POSIX ACLs via NFSv3.  it was never
standardized, so some implementations provide this support, and others
do not.  Solaris was the first O/S to get this support.

i believe what ag's patch set provides is "POSIX ACL support" which
means he has added the generic file system interfaces needed to support
ACLs as they are described in the POSIX standards.  "Solaris ACL
support" means using the Sun-defined NFS side-band protocol to access
and modify POSIX ACLs via an NFS client.

Linux (in 2.4 kernels) does not provide support for accessing and
modifiying ACLs on the server via NFS.  neither the client side nor the
server side support is there.  there are some patches against 2.4 that
provide this support on both sides, and i believe they are part of ag's
ACL patch set.

note that NFSv3 clients can still respect the server-side ACL settings
because with v3, a new operation, called ACCESS, was added to allow
clients that don't support fine-grained access control to honor the ACL
settings on the server.  instead of basing access control strictly on a
file's mode bits, an NFSv3 client uses an ACCESS operation to see if
there are any other access restrictions on a file that are not visible
via the file's attributes.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
