From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: network storage solutions
Date: Fri, 16 May 2003 09:16:14 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C61131274DE@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: "Josip Loncaric" <josip@lanl.gov>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Ghsl-0005pm-00
	for <nfs@lists.sourceforge.net>; Fri, 16 May 2003 09:16:31 -0700
To: "Jeffrey B. Layton" <laytonjb@bellsouth.net>, <beowulf@beowulf.org>
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

> > We've had similar problems while I was at ICASE.  "Hard"=20
> mounts would=20
> > lock up client processes (even unmount) when the NFS server=20
> went down,=20
> > but "soft" mounts were "too soft" for some of our users.  A=20
> reasonable=20
> > solution is to "harden" your soft mounts by insisting on=20
> longer major=20
> > timeouts, as in "retrans=3D15" (the default is 3).=20
>=20
>=20
> I still think this is dangerous. With soft mounts you can
> still get silent data corruption despite the longer timeouts.
> Chuck, do you agree?

yes. there is always a probability of corruption if there is
the possibility that the client will give up before the
operation has completed.

you can reduce that probability by following the suggestions
i posted yesterday.


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
