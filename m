From: Thomas Lenherr <thomas@lenherr.name>
Subject: nfs corrupts files
Date: Thu, 14 Oct 2004 18:14:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <416EA5F4.5090701@lenherr.name>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5B4F55BC2D31C64ADE76F8AB"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CI8Fi-0004Cd-5K
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 09:14:54 -0700
Received: from mx8.bluewin.ch ([195.186.4.211])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CI8Fg-00087O-TZ
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 09:14:54 -0700
Received: from mephisto.lenherr.name (83.76.51.231) by mx8.bluewin.ch (Bluewin AG 7.0.030.2)
        id 4164061100382DA2 for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 16:14:46 +0000
Received: from [10.0.0.10] (baal.lenherr.name [10.0.0.10])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mephisto.lenherr.name (Postfix) with ESMTP id 19422391AA
	for <nfs@lists.sourceforge.net>; Thu, 14 Oct 2004 18:14:46 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5B4F55BC2D31C64ADE76F8AB
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

hi everyone,

ok, here is what i did:
i had some files on an nfs-server (v3) using kernel 2.6.8-gentoo-r8
(updated because of the trouble). the 9 files had an average size of
about 180mB and i built the md5sums of these files via ssh _on_ this
server.

after that i transferred these files to my workstation, once via nfs and
once via smb and let them check with md5sum again. the files transferred
with smb were ok, but 6 of the 9 files tranferred via nfs were corrupt.
then i made cmp between the local files (transferred with nfs of course)
and the files on the nfs-server. the result:
1) multiple use of cmp on files which md5sum mentioned as corrupt
resulted in reporting differences at different positions
2) sometimes the usage of cmp on files which md5sum mentioned as correct
resulted in reporting differences...

so, as you see, there's definitly something wrong
now some further infos:
there are no log messages either on the client nor on the server.

export-config:
---------------------------------------------------
mephisto root # exportfs -v
/raid/data/public/media
                      baal(rw,wdelay,nohide,no_root_squash)
/raid/data      baal(rw,wdelay,no_root_squash)
---------------------------------------------------
mephisto is my servername, baal is my clientname and the subdirectory
has to be reexported as it is a new mount-point

the line from the /etc/fstab on client:
---------------------------------------------------
thomas@baal thomas $ grep nfs /etc/fstab
mephisto:/raid/data/    /data           nfs             rw,hard,intr    0 0
---------------------------------------------------


i'm thankful for any help as i don't know, where the mistake might be....

thomas

--------------enig5B4F55BC2D31C64ADE76F8AB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBbqX03E1pPHX30VoRAnxmAJ9Bew1zAZ6Nezo0cYbo31cgscqnHACgxNIa
IJhjk/RiLJZ0AI1O/BSiOzs=
=E0bN
-----END PGP SIGNATURE-----

--------------enig5B4F55BC2D31C64ADE76F8AB--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
