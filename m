From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: recursive NFS export of mounted ISO images
Date: 23 Oct 2002 16:07:09 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1035403629.31676.34.camel@opus>
References: <Pine.LNX.4.44.0210231440430.31286-100000@wopr.wolfram.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-Nsp8x+CB3AM0NgPRFsIa"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 184Rma-0005hI-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Oct 2002 13:07:12 -0700
To: Dave Ingram <davei@wolfram.com>
In-Reply-To: <Pine.LNX.4.44.0210231440430.31286-100000@wopr.wolfram.com>
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


--=-Nsp8x+CB3AM0NgPRFsIa
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2002-10-23 at 15:51, Dave Ingram wrote:
>=20
> 	Hello, we're trying to do something a little odd in NFS that I=20
> don't believe is currently possible. However, I have seen in the mail=20
> archives that Neil Brown discussed this back in 7-4-2001.
>=20
> 	The problem is this:
>=20
> 	We have a huge RAID system that houses, among other things, many=20
> ISO image files.
>=20
> 	The quality assurance people would like to have a "virtual=20
> jukebox" that is distributed via NFS to our large array of test machines.=
=20
> This jukebox would contain the mounted ISO images.
>=20
> 	However, currently there is no way to have a single parent=20
> directory distributed over NFS that will propogate its mounted contents.=20
> One must currently define an explicit mount point in /etc/exports (eg:=20
> /Jukebox/M-LINUX-L/6.0.0/187885). Additionally, the client must know the=20
> explicit mount point to properly mount this shared image.
>=20
> 	This is a problem when you want to have several hundred (well, no=20
> more than 255 theoretically because of the 8-bit 'minor' device issue wit=
h=20
> loop devices) ISO images that you'd like to distribute, because you then=20
> are responsible for maintaining EVERY explicit mount point for each image=
,=20
> both on the server and each client.
>=20
> 	Even more frustrating is the fact that this is going to be an=20
> automated dynamic process. That is - as ISO images are automatically buil=
t=20
> by other systems, we'll want to mount and export their contents=20
> automatically. Likewise, we'll need to prune existing ISO images and thei=
r=20
> respective mounts.
>=20
> 	And, there is no way for the client-side to "know" each mount=20
> point in an automated fashion. That is - if the ISO builder system=20
> generates a new ISO image, mounts it, and distributes it, there is now a=20
> unique mount point that the client can't programatically determine.
>=20
> 	So - why the heck am I bothering NFS people with this?
>=20
> 	Because I am wondering if there is a way to simply have ONE mount=20
> point exported and mounted on the client side, and have it recursively=20
> inherit each of the mounted image directories within it.
>=20
> 	Also - for those who are asking, "Hey dummy - why don't you just=20
> mount the images on the NFS server, then copy their contents into /Jukebo=
x=20
> in the appropriate directory?!". Well, because our quality assurance=20
> people would like to work with the EXACT files that are going to get=20
> burned to CD if the build is a success. Copying the files introduces an=20
> extra step that makes them nervous. Plus - every ISO image whose contents=
=20
> we must actually COPY means another 600+ megs we have to allocate disk to=
.
>=20
> 	Thoughts, anyone?
>=20
> 	If all you can say is, "That's impossible" or "You're a moron" -=20
> your reply will find its way into /dev/null. :-)
>=20

You might be able to work some dark magic with autofs over the nfs
exported locations.

look into how autofs functions - I think it might just be possible if
you're not afraid of some painful thinking.

-sv


--=-Nsp8x+CB3AM0NgPRFsIa
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQA9twFt1Aj3x2mIbMcRAlkrAJ431MkoynMF6MBKpNhcsZnSos87DgCgjm8C
N0S5ZyMXrccwtqR9OlGt1/s=
=opZ/
-----END PGP SIGNATURE-----

--=-Nsp8x+CB3AM0NgPRFsIa--



-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0002en

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
