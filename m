From: Peter Astrand <peter@cendio.se>
Subject: RE: [NFS] NFSv3 ACL status?
Date: Thu, 12 Aug 2004 16:22:53 +0200 (CEST)
Sender: acl-devel-bounces@bestbits.at
Message-ID: <Pine.LNX.4.44.0408121620001.18011-100000@maggie.lkpg.cendio.se>
References: <482A3FA0050D21419C269D13989C611302B07DC0@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, acl-devel@bestbits.at
Return-path: <acl-devel-bounces@bestbits.at>
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611302B07DC0@lavender-fe.eng.netapp.com>
List-Unsubscribe: <http://acl.bestbits.at/mailman/listinfo/acl-devel>,
	<mailto:acl-devel-request@bestbits.at?subject=unsubscribe>
List-Archive: <http://acl.bestbits.at/pipermail/acl-devel>
List-Post: <mailto:acl-devel@bestbits.at>
List-Help: <mailto:acl-devel-request@bestbits.at?subject=help>
List-Subscribe: <http://acl.bestbits.at/mailman/listinfo/acl-devel>,
	<mailto:acl-devel-request@bestbits.at?subject=subscribe>
Errors-To: acl-devel-bounces@bestbits.at
List-ID: <nfs.lists.sourceforge.net>

> > But: http://acl.bestbits.at/ seems to indicate that ACLs over=20
> > NFSv3 actually works, and provides patches for 2.6.1, but I=20
> > can't find any information about if this patch is really=20
> > needed for modern kernels
> > (2.6.7) or modern distributions. Is this patch for the=20
> > server, client or=20
> > both?=20
>=20
> Solaris ACL support is in some kernels but not others.  i believe RHEL
> 3.0 includes Solaris ACL support for both the NFS client and server, fo=
r
> example, as an extra patch.  stock 2.4 does not.

Now I'm confused. Is "Solaris ACL support" something different than the
generic ACL patches Andreas provides?


> i believe there is a plan to include Solaris NFSv3 ACL support in the
> 2.6 client and server at some point in the near future so that everyone
> will get the same implementation, and the distributions won't have to
> add a separate patch if they need it.

That would be great.=20


> the Linux NFSv4 client/server implementation is getting ACL support
> right now.  there are issues with how to map POSIX ACLs (which Linux

Currently, I'm not interested in v4 ACLs.=20


--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00


_______________________________________________
acl-devel mailing list
acl-devel@bestbits.at
http://acl.bestbits.at/mailman/listinfo/acl-devel
