From: Thomas Lenherr <thomas@lenherr.name>
Subject: Re: nfs corrupts files
Date: Thu, 14 Oct 2004 21:58:22 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <416EDA5E.4020000@lenherr.name>
References: <416EA5F4.5090701@lenherr.name> <1097774783.18925.10.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig77A7FC1DA31A3C086EED1846"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CIBkM-0005x9-Bt
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 12:58:46 -0700
Received: from mx8.bluewin.ch ([195.186.4.211])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CIBkJ-0007t8-UU
	for nfs@lists.sourceforge.net; Thu, 14 Oct 2004 12:58:46 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1097774783.18925.10.camel@lade.trondhjem.org>
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
--------------enig77A7FC1DA31A3C086EED1846
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: Quoted-Printable

sorry, for forgetting the kernel of the workstation, it's yet another=20
gentoo-kernel: 2.6.7-gentoo-r6.
i looked up the difference between the vanilla kernel 2.6.7 and this=20
patched gentoo-version
and it seems it's not really much, just stuff like bootsplash, console=20
speakup and something
about making it ready for supermount...

anyway, as you said i installed the original 2.6.8.1 on the server and=20
tried the whole
thing again, what means i copied the 9 files over nfs and let them check=20
with md5sum.
same result :(

i did not yet update the kernel of the workstation, because i accessed=20
the nfs server
with an windows-implementation of nfs and experienced the same troubles.=20
so i think
the server is the faulty one...

cheers,
thomas



Trond Myklebust wrote:

>P=E5 to , 14/10/2004 klokka 18:14, skreiv Thomas Lenherr:
>
> =20
>
>>ok, here is what i did:
>>i had some files on an nfs-server (v3) using kernel 2.6.8-gentoo-r8
>>(updated because of the trouble). the 9 files had an average size of
>>about 180mB and i built the md5sums of these files via ssh _on_ this
>>server.
>>
>>after that i transferred these files to my workstation, once via nfs an=
d
>>once via smb and let them check with md5sum again. the files transferre=
d
>>with smb were ok, but 6 of the 9 files tranferred via nfs were corrupt.
>>then i made cmp between the local files (transferred with nfs of course=
)
>>and the files on the nfs-server. the result:
>>1) multiple use of cmp on files which md5sum mentioned as corrupt
>>resulted in reporting differences at different positions
>>2) sometimes the usage of cmp on files which md5sum mentioned as correc=
t
>>resulted in reporting differences...
>>   =20
>>
>
>You don't mention which kernel the client was running. Was it the same
>as the server?
>
>Have you tried just grabbing a kernel 2.6.8.1 from ftp.kernel.org, and
>compiling it up (using the same .config as the gentoo kernel if you
>like) and then doing the same thing? I ask 'cos I just don't know what
>is in the gentoo kernels.
>
>Cheers,
>  Trond
>
>
>
>-------------------------------------------------------
>This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
>Use IT products in your business? Tell us what you think of them. Give u=
s
>Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out m=
ore
>http://productguide.itmanagersjournal.com/guidepromo.tmpl
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
> =20
>

--------------enig77A7FC1DA31A3C086EED1846
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBbtpj3E1pPHX30VoRAuwiAKDHF7Z6C0ImCm38MNTo1wLeoYLKIwCgo8BM
eWcIgbnbY5lJgGiRudStK6E=
=AvdF
-----END PGP SIGNATURE-----

--------------enig77A7FC1DA31A3C086EED1846--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
