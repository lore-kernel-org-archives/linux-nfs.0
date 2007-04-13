From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Thu, 12 Apr 2007 21:09:03 -0400
Message-ID: <200704122109.04535.vapier@gentoo.org>
References: <17950.44333.118970.276558@notabene.brown>
	<200704122055.12223.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_wgtHGfHlBSQVcZ4"
Cc: Neil Brown <neilb@suse.de>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcAGz-0005iT-R8
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 18:08:22 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HcAH1-0001bV-2b
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 18:08:24 -0700
In-Reply-To: <200704122055.12223.vapier@gentoo.org>
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

--Boundary-00=_wgtHGfHlBSQVcZ4
Content-Type: multipart/signed; boundary="nextPart1950651.nHesPxAIV3";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1950651.nHesPxAIV3
Content-Type: text/plain;
  charset="iso-8859-6"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 12 April 2007, Mike Frysinger wrote:
> if that's true, then we could at least rewrite the socket code to bind to
> ports that do not appear in /etc/services (via getservbyport()) ... that'd
> allow admins to easily prevent things like mountd/statd from hijacking
> reserved ports ...

actually, it can be done regardless of how the socket is obtained ... attac=
hed=20
is a function i wrote to address this issue but didnt get around to=20
integrating into packages

what do you think ?
=2Dmike

--nextPart1950651.nHesPxAIV3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIUAwUARh7YMEFjO5/oN/WBAQLp8w/1FHJk14FaCsA8ue3Z/t3+kjcmKBFVcqNU
yIVVlbwre9tRsYpz9USfBRIkkDtVD+t9Ws3Yj7JNxAVp6AIZz5omhVWr5IreMOxB
DAfXtKB43+CdcjvU0f2VsnkUOOg/kWKUdOWB0CVG2SLbbCE6jDrmkE5kUjCTxqbv
EaOO15kGLmsIrCKMIn+i56Gh46f75Aex+9M7IAc/iHVX5WdcwGyNrgR6S19nojDe
xdNKYhiKNfTn/m45pzozjabwfdgwaIPNoxzyh5fNXs29hVlqQUbYLMacSxCQR0By
jBcD5oeIeqEsw2vLYfhyK67PykKWZFhiLiTlE8JsIjc2dQuJvB3fkQe4aeaiDsfY
WmzslqaDVj+F/7Y5Yt1CJ616+sKW+99WR05/1wlC5KdtbG4huQPTsrpXWqnTADOp
v8/G2zqogoTyMa6xE57nUwy0qMqybdvKLpaCptFQeDOmOs9eB7yGOCTZZ/0hDdxP
BdHxH73JFAQGYK1T3V6dDPq7Ya3UKxhmtI0STE05KcPdGf7LRY0a+yg7uaKoDgFC
4cl/nGrjEmetX7Xvt16PWuPwDz8A6zkaFYAMoijV/IbW1nMlDTTZKf9Kc3AYp6Al
dBQ2KQHrxZEkdP8d0VmbGn6YCtO9jwnIQBR+RkSSAPOm1G6vP0OoJknCGh8X2ENM
Fn6hZm0OgA==
=DzQ7
-----END PGP SIGNATURE-----

--nextPart1950651.nHesPxAIV3--

--Boundary-00=_wgtHGfHlBSQVcZ4
Content-Type: text/x-csrc;
  charset="iso-8859-6";
  name="bindresport.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="bindresport.c"

#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>

/* Allocate a privileged port that is not reserved according to
 * the /etc/services database.  This allows the user to reserve
 * mark ports as "taken" by updating that file rather than having
 * a ton of packages install a ton of little files that somehow
 * magically get accumulated to reserve ports ...
 * http://bugs.gentoo.org/77810
 *
 * We do this recursively so that we dont have to worry about the
 * libc rebinding the same privileged port over and over again.
 * We keep all the sockets open until we find one we're happy
 * with and we keep it.
 */
int bind_unreserved_port(int domain, int type, char *protocol)
{
	int s;
	struct servent *serv;
	struct sockaddr_in saddr;
	socklen_t slen;

	/* allocate a socket */
	s = socket(domain, type, 0);
	if (s < 0)
		return s;

	/* attempt to bind to port */
	if (bindresvport(s, (struct sockaddr_in *) 0) != 0)
		goto err_close;

	/* make sure we only bind to non-reserved ports */
	if (getsockname(s, (struct sockaddr *)&saddr, &slen) != 0)
		goto err_close;

	serv = getservbyport(saddr.sin_port, protocol);
	if (serv != NULL) {
		/* this port is listed in /etc/services, so let's try again */
		int punt_socket = s;
		s = bind_unreserved_port(domain, type, protocol);
		close(punt_socket);
	}

	/* awesome, got ourselves a decent port */
	return s;

err_close:
	close(s);
	return -1;
}

--Boundary-00=_wgtHGfHlBSQVcZ4
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--Boundary-00=_wgtHGfHlBSQVcZ4
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--Boundary-00=_wgtHGfHlBSQVcZ4--
