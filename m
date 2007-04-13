From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Thu, 12 Apr 2007 22:04:09 -0400
Message-ID: <200704122204.10304.vapier@gentoo.org>
References: <17950.44333.118970.276558@notabene.brown>
	<200704122055.12223.vapier@gentoo.org>
	<17950.57188.878877.547112@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0330199392=="
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HcB8L-0002oY-Ps
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 19:03:30 -0700
Received: from smtp.gentoo.org ([140.211.166.183])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HcB8M-0005Jr-Am
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 19:03:31 -0700
In-Reply-To: <17950.57188.878877.547112@notabene.brown>
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

--===============0330199392==
Content-Type: multipart/signed; boundary="nextPart1742595.rmeeFoFr24";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1742595.rmeeFoFr24
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 12 April 2007, Neil Brown wrote:
> There are supposed to be some ranges which are never assigned.
> According to
>   http://www.iana.org/assignments/port-numbers
>
>     DYNAMIC AND/OR PRIVATE PORTS
>
>     The Dynamic and/or Private Ports are those from 49152 through 65535
>
> as long as we choose one of those (and that is what happens if you
> just let the kernel decide for you) there must be no conflict.

hmm, true ... that is much simpler to grab random ports in that range :)

> I had thought of that too.  I'll probably implement it.  Your code (in
> subsequent email) is a little more complicated than needed.  Just
> repeatedly call bindresvport, closing if you don't like it.  The port
> number tried increments each time.

is that guaranteed somewhere ?  when i first worked on the code snippet, i=
=20
looked for such info and since i couldnt locate any such "the implementatio=
n=20
must increment" requirement, i felt the more complicated recursive approach=
=20
is better since relying on Linux/glibc behavior is not appropriate ...
=2Dmike

--nextPart1742595.rmeeFoFr24
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.3 (GNU/Linux)

iQIVAwUARh7lGkFjO5/oN/WBAQLl/RAAxSLwhKlRc/FNN+DP4eBMamrO7XgnHNyj
9ghn543Nd58A3ku62Aio7Zxk3H1VpO9FUBBiOr2ky8alELMRrOvWrDWjZZluinnO
ghOSfiG6mu8PjMh8L3LCZmjSd4CCgB8ZCvatRi647PgsBEyQwphnAS0pzcj6ErlE
U8C2gWBsAexLPMYuJcuH56kn0pddCViI8zZygRA+LjG9n5rCXJZeQOO/h9DBk9Rb
h410L/4ZGsDpswNfRVLhjF37xczfrPfYYF1TPIS2YYmpp+uwuGFzl3rY2TeGd0et
VNNYSRlVgAN2wtSbaKyE5+Id+0/imcFv/IN0KvY02R2WqYamRyFFXXwtGDhFIAbv
1YdgB1NcnLRSoIo0+5VtYpyM+Y/7JLgeHXu0MWEKNhWjMzEW9gghvRZ8YIh9/LL+
lnkvc/uISPdcSrGh4Sul7niSPw2J7+oxUWbyKkNI/jI0k+1mzEtL3W3vX8oexL8b
xsyp3eQGZIGduNRrTFC0Jlk24UB4wbNi3ACneAUh56XwRwkEpLSSeMOiW7wVgUKz
NP6Ed+fkbZbCzv7rnPllo1mf2Xa5RGy6GuwiUXhyErBnjlWwcO3CXmrhMXg2WJc9
6lAI1a6rxTJO71znP22sJv4+ops+HPpinousj2qG5aMxWZY8PI6zU5AgkyAxKlZe
T3gJ8B2WTtA=
=dhFA
-----END PGP SIGNATURE-----

--nextPart1742595.rmeeFoFr24--


--===============0330199392==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
--===============0330199392==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0330199392==--
