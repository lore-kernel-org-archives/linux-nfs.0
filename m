From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Linux client, SNAP filer, ESTALE
Date: Wed, 28 May 2003 07:46:00 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611312753D@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19L2CM-0007RO-00
	for <nfs@lists.sourceforge.net>; Wed, 28 May 2003 07:46:38 -0700
To: "Edward Hibbert" <EH@dataconnection.com>
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

hi edward-

> I have an ESTALE problem.  That probably means it's been=20
> discussed to death,
> but after browsing the archive I'm not much the wiser, so...
>=20
> Here's the scenario:
> *	RH 7.2 running a 2.4.18 kernel
> *	Linux boxes acting as NFS clients to a SNAP filer.
> *	Mount options rw,noac,rsize=3D4096,wsize=3D4096,hard,intr,bg
>=20
> We had a power outage on the filer; the clients stayed up. =20
> The clients
> returned stale errors, even once the filer had come back up, until we
> unmounted and remounted all the mount points.
>=20
> Is this behaviour as expected, a known problem, an unknown=20
> problem, or too
> sloppily described to be able to tell?

we've had several credible reports of this kind of behavior
against many releases of 2.4 recently, so it is a known problem.
but we haven't had a good chance to drill into to it, so we
don't know what is happening.


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
