From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: async vs. sync
Date: Mon, 26 Jul 2004 23:28:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200407262328.07704.bernd-schubert@web.de>
References: <482A3FA0050D21419C269D13989C61130435E523@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  protocol="application/pgp-signature";
  micalg=pgp-sha1;
  boundary="Boundary-02=_ndXBBp1a6ogqu6J";
  charset="iso-8859-1"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpD1A-0006Am-J6
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 14:28:20 -0700
Received: from smtp07.web.de ([217.72.192.225])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpD19-0008PQ-QR
	for nfs@lists.sourceforge.net; Mon, 26 Jul 2004 14:28:20 -0700
To: "Lever, Charles" <cel@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435E523@lavender-fe.eng.netapp.com>
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


--Boundary-02=_ndXBBp1a6ogqu6J
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 26 July 2004 19:21, you wrote:
> sorry i'm not copying the list... our local exchange server changed my
> outgoing To: address a couple of weeks ago, and i still haven't gotten
> the list moderator's attention to fix up my e-mail address.

No problem, I will send a full quote to the list.

>
> > Exactly, therefore I would like to enable the sync-export
> > option again.
> > However, reducing the speed to about 1/5 of async speed for
> > large files and
> > to about 1/20 for smaller files is not an option. The people already
> > complained that compiling their projects takes ages now...
> >
> > D'oh, sorry, I forgot to write that we use the tcp-mounts and
> > nfs3. So  those
> > numbers really shouldn't happen, should they?
>
> if the server is working correctly, theoretically this should not
> happen.
>
> are you using strange mount options on the client, such as "noac" or
> "sync" ?  "async" on the client is perfectly OK to use; it's the server
> side export option that is badness.

No, I think not. Here's the fstab line for /home:
hamilton:/home /home  nfs rsize=3D8192,wsize=3D8192,hard,intr,tcp  0  0

Here's something that is for me pretty interesting (since I don't completel=
y=20
understand whats causing it):

1.) The export option is changed on the server from sync to async,=20
'exportfs -rav' is executed.

2.) One client had mounted with the async-mount option, all other clients=20
without this option. No client remounts /home after the the export option w=
as=20
changed on the server.

3.) All but the one client now can write to the server with 5MB/s for large=
=20
*and* small files. However the client which has mounted with the async-moun=
t=20
option can now write with full 100MBit (so 11 MB/s) to the server.

4.) Of course, remounting /home on any client even without giving the=20
async-mount option, gives back full write speed to all clients now.

Is the behaviour from 3) intented to happen? Actually I thought that a remo=
unt=20
on the clients is necessary to gain back full write speed.

Thanks,
	Bernd

--Boundary-02=_ndXBBp1a6ogqu6J
Content-Type: application/pgp-signature
Content-Description: signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBBBXdnC8BUnAF+ydYRAtHOAJ42xmjrUrNBKNH3EsEsDeMndy0bEACaA84C
SNFQv/cYBXQ5zwXTco5l1/U=
=DI9X
-----END PGP SIGNATURE-----

--Boundary-02=_ndXBBp1a6ogqu6J--


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
