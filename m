From: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Subject: Re: [NFS] NFS performance debugging
Date: Wed, 25 Jun 2008 09:02:42 +0200
Message-ID: <200806250902.42880@fortytwo.ch>
References: <200806231659.58158@fortytwo.ch> <200806241217.29243@fortytwo.ch>
	<20080624202931.GA22757@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0404924288=="
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60773 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751847AbYFYHDM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2008 03:03:12 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KBP25-00020q-To
	for linux-nfs@vger.kernel.org; Wed, 25 Jun 2008 17:03:10 +1000
In-Reply-To: <20080624202931.GA22757@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============0404924288==
Content-Type: multipart/signed; boundary="nextPart2433642.lOv0ZIGa9X";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2433642.lOv0ZIGa9X
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 24 June 2008 22.29:31 J. Bruce Fields wrote:
> On Tue, Jun 24, 2008 at 12:17:24PM +0200, Adrian von Bidder wrote:

> > Starting KDE, opening documents, sometimes also closing oo.org and
> > saving documents takes several seconds longer than on local disk.
>
> "close" on nfs is an operation that requires a round-trip to the server
> and waiting for the disk to commit any writes made before the close, so
> if you've got to do a lot of those it can take time.  Fooling with the
> journaling on the exported filesystem may help.

Are there tools to measure latencies on NFS?  Given a network dump, desired=
=20
output would be histograms of latencies by file operation?  (Or maybe I can=
=20
catch the information on the client, VFS side instead of NFS?

At this time, I really need to collect more data on where the problem is=20
since all I'm doing right now is fooling around based on assumptions... :-(

OTOH I'd suspect KDE/oo.org startup to be mostly reads of those config=20
files, so the problem shouldn't be close latencies.  Assumptions again.

> > TODO today: play around with NFSv4 on the shaky assumption that nfsv3
> > is actually working but net latency is killing my performance.
>
> Delegations *might* help if the problem is really open latency.

=46irst tries showed
 * There are no acl on my files now
 * user id mapping seems funny: some users map to nobody, others map=20
correctly.  Huh?
 * Performance seems to be ok (timing desktop applications is always=20
difficult, and so far I'm working against on the production server with=20
varying load anyway...)

Haven't investigated these yet...

cheers
=2D- vbi


=2D-=20
Today is Sweetmorn, the 30th day of Confusion in the YOLD 3174

--nextPart2433642.lOv0ZIGa9X
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: get my key from http://fortytwo.ch/gpg/92082481

iKcEABECAGcFAkhh7ZJgGmh0dHA6Ly9mb3J0eXR3by5jaC9sZWdhbC9ncGcvZW1h
aWwuMjAwMjA4MjI/dmVyc2lvbj0xLjUmbWQ1c3VtPTVkZmY4NjhkMTE4NDMyNzYw
NzFiMjVlYjcwMDZkYTNlAAoJECqqZti935l6KZUAn3ZoO/Tp85x7PK40+elQFw+N
Bls1AJ9tZ5GdhBBZv+0hh7PDmtteOrXfyQ==
=DUdg
-----END PGP SIGNATURE-----

--nextPart2433642.lOv0ZIGa9X--


--===============0404924288==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============0404924288==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============0404924288==--


