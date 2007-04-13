From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Thu, 12 Apr 2007 20:55:11 -0400
Message-ID: <200704122055.12223.vapier@gentoo.org>
References: <17950.44333.118970.276558@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0634980272=="
Cc: Neil Brown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcA3Y-0004GF-KV
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 17:54:28 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HcA3b-0006uk-0j
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 17:54:31 -0700
In-Reply-To: <17950.44333.118970.276558@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

--===============0634980272==
Content-Type: multipart/signed; boundary="nextPart1192517.5PUcAH1vtv";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1192517.5PUcAH1vtv
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 12 April 2007, Neil Brown wrote:
> mountd/statd currently bind to privileged ports to listen for
> requests.
>
> This is really a bad thing to do as there is no range of privilege
> ports that is guaranteed not to be assigned to some service.

s/privilege// ... you have the same problem regardless of privilege state .=
=2E.=20
svn/mysql/postgresql/etc... can be just as troublesome for people

redhat has a long standing open bug on the topic with no real workable=20
solution (the one posted requires a lot of overhad as every package needs=20
to "opt-in" with the process)

> But is there some reason that mountd/statd need a priv port that I
> haven't thought of?

if that's true, then we could at least rewrite the socket code to bind to=20
ports that do not appear in /etc/services (via getservbyport()) ... that'd=
=20
allow admins to easily prevent things like mountd/statd from hijacking=20
reserved ports ...

i just wish all the rpc things *asked portmap* for the port so we could put=
=20
all of this logic in portmap and not duplicate effort across all rpc=20
daemons :(
=2Dmike

--nextPart1192517.5PUcAH1vtv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARh7U70FjO5/oN/WBAQKy4g//ambeK/qeLs+5L3gbAfxiOwIp9Ti5KJmT
NhJYIjzixmvNPqvnf/+T1CeCFZikErzp/O5BekbLR6eX0iHF3JNNhlmMQLsv+3HR
jd2CwMlQOJt3oSZDqIfOuicJ5kCTjJbut1RyHjrwcoMVM72l/HLTFNPsBeXiNO5p
MqjO/ogym1ecbnpJgeB/N/tWXuVPpVWaZsRtg34TzFjWCLQTTdYwcGSLQf7zFaMt
1aZIRC41RFl1AkpkJB70oXar56J/oBNEDXCHDF+GvZ+EtG+mhH1jPm0wspLdZNTR
ZqWHt9Wv5vx+o0sPO0vnzNAqE/NGFJ4za0RDoQPtShvMKFNxghO7tFA5HRSdRXNF
nJwT6kzdv/d8OEKkCWby4qLkqcIW8YziHLYrykQTyPBJVgEtoitqUmqVTX1bhhkC
VXsgziD/rHjFk3gv/f0Lr9ZQj0WAFvwXMW3wi9xFYWVFZMjADuoDmMI19tcmXyfw
lY7psNGGN5RNfeECuGcRsFgb+64C1KMQj6XyDqnQeZ/fHL0FdJWKiPEw8YBeI4dC
HRHY+/vdk2ccvrd5l3ZPdA40Dx8C+km0K3E9FEIH58fnRsvgb5qx33BS+f9AjqsS
/gB11F0ySBnUxw4Xnj/UddmAYPSDAlw3uDtuxLAk8EAR6LbbE6gZvCIqi8l7gRBB
8BpbiCQfIgQ=
=l9H9
-----END PGP SIGNATURE-----

--nextPart1192517.5PUcAH1vtv--


--===============0634980272==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0634980272==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0634980272==--
