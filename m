From: Peter Astrand <peter@cendio.se>
Subject: RE: [NFS] NFSv3 ACL status?
Date: Thu, 12 Aug 2004 17:14:57 +0200 (CEST)
Sender: acl-devel-bounces@bestbits.at
Message-ID: <Pine.LNX.4.44.0408121711240.19647-100000@maggie.lkpg.cendio.se>
References: <482A3FA0050D21419C269D13989C611302B07DC1@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, acl-devel@bestbits.at
Return-path: <acl-devel-bounces@bestbits.at>
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07DC1@lavender-fe.eng.netapp.com>
List-Unsubscribe: <http://acl.bestbits.at/mailman/listinfo/acl-devel>,
	<mailto:acl-devel-request@bestbits.at?subject=unsubscribe>
List-Archive: <http://acl.bestbits.at/pipermail/acl-devel>
List-Post: <mailto:acl-devel@bestbits.at>
List-Help: <mailto:acl-devel-request@bestbits.at?subject=help>
List-Subscribe: <http://acl.bestbits.at/mailman/listinfo/acl-devel>,
	<mailto:acl-devel-request@bestbits.at?subject=subscribe>
Errors-To: acl-devel-bounces@bestbits.at
List-ID: <nfs.lists.sourceforge.net>

> > believe RHEL=20
> > > 3.0 includes Solaris ACL support for both the NFS client=20
> > and server,=20
> > > for example, as an extra patch.  stock 2.4 does not.
> >=20
> > Now I'm confused. Is "Solaris ACL support" something=20
> > different than the generic ACL patches Andreas provides?
>=20
> Sun created a side-band NFS-related protocol (like NLM or NSM) to allow
> NFS clients to access and modify POSIX ACLs via NFSv3.  it was never
> standardized, so some implementations provide this support, and others

Yeah, I know all this.=20


> ACLs as they are described in the POSIX standards.  "Solaris ACL
> support" means using the Sun-defined NFS side-band protocol to access
> and modify POSIX ACLs via an NFS client.
>=20
> Linux (in 2.4 kernels) does not provide support for accessing and
> modifiying ACLs on the server via NFS.  neither the client side nor the
> server side support is there.  there are some patches against 2.4 that
> provide this support on both sides, and i believe they are part of ag's
> ACL patch set.

Can anyone confirm that the "RHEL 3.0 Solaris ACL support" is really AG's=
=20
ACL patches?

--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00


_______________________________________________
acl-devel mailing list
acl-devel@bestbits.at
http://acl.bestbits.at/mailman/listinfo/acl-devel
