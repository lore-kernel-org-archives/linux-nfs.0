From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: RE: RE: 2.4.19 NFSALL performance oddity
Date: Wed, 9 Oct 2002 10:01:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B9160C7734@poexmb3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zILL-0000KF-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 08:01:47 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>



> -----Original Message-----
> From:	Lever, Charles [SMTP:Charles.Lever@netapp.com]
> Sent:	Wednesday, October 09, 2002 9:18 AM
> To:	Heflin, Roger A.
> Cc:	'nfs@lists.sourceforge.net'
> Subject:	RE: [NFS] RE: 2.4.19 NFSALL performance oddity
>=20
> > I have tried it both with and without Neil's patches, they don't
> > make it better and don't make it worse.  Runing the server/client
> > tcp makes things a little bit worse.
> >=20
> > We should be using sync on the mount option, correct? =20
>=20
> no, only use sync in the exports file on the server.
>=20
> use the sync mount option on the client only if you require
> all writes to be pushed to the server's disk before the client
> gives control back to your application.  (certain databases
> require this option, but it is not normally needed).
>=20
	For some stuff we do this might be useful, but not if it was
	to slow down the io.

> > All of my tests used sync on the mount and sync in the export,
> > previously when using async on 2.2.xx (on the export side),=20
> > and not using the sync option on the mount appeared to cause
> > issues under heavy loads, ie the out of slots warnings, and
> > sometimes worse.
>=20
> that might be an interesting issue to pursue some time.
>=20
	I am trying to verify I can still make this happen,  I know
	with 2.2.16 server, and clients, with async on both exports
	and mount I would get clients getting out of slots and crashing
	if the disk server went down for an extended period of time,
	and I also believe that I could get the server to sometimes
	crash by overloading it with writes.   I am currently trying to
	duplicate this with a 2.4 server, in a few hours I should know.

	We had at least one occasion were our monitoring server
	when down (every machine was updating 3-4 files every
	minute or so), and had about 1/4-1/3 of the clients developed
	issues with out of slot errors, the machine actually required=20
	a reboot to make it useful again.

> > I did look and it appears that how the sync option on the
> > mount command changed sometime in 2001, someplace
> > in the 2.4 series.
>=20
> the mount command is a user-land utility.  i'm not sure
> you could tie a change in its behavior to a specific
> kernel version.
>=20
	There were some messages from Trond about changing
	how the kernel interprets the sync option, apparently in
	a version of 2.2 sync only synced the directory info, and
	not the data and at some point in time it was changed=20
	to sync the actual data, this is probably the change that
	makes the difference in the speed between the 2.2 and
	2.4 client.  It does sound like a perfectly reasonable thing
	do to, and it suprises me that it was not syncing everything
	originally.

							Roger


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
