From: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Subject: Re: [NFS] NFS performance debugging
Date: Tue, 24 Jun 2008 12:17:24 +0200
Message-ID: <200806241217.29243@fortytwo.ch>
References: <200806231659.58158@fortytwo.ch>
	<20080623192836.GI24373@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0565378231=="
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45323 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406AbYFXKRp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jun 2008 06:17:45 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KB5ao-0003zw-OB
	for linux-nfs@vger.kernel.org; Tue, 24 Jun 2008 20:17:42 +1000
In-Reply-To: <20080623192836.GI24373@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============0565378231==
Content-Type: multipart/signed; boundary="nextPart2960845.esMhaXLicq";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart2960845.esMhaXLicq
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi again,

Thanks for your replies (You too, Trond)

On Monday 23 June 2008 21.28:36 you wrote:

[... NFS performance ...]

> In what way exactly is it sluggish?

Starting KDE, opening documents, sometimes also closing oo.org and saving=20
documents takes several seconds longer than on local disk.

Certainly network latency (especially with these silly lots of small config=
=20
files) takes some time, but I'm still surprised.  At the same time, I don't=
=20
have data to compare a "known good" NFS against ours, so perhaps NFS is=20
indeed so slow?

>
> > tcpdump shows many "reply ERR 1448" etc. msgs whenever NFS activitiy is
> > going on (both stat like with "find /home" or read/write with dd)
>
> I'm afraid I don't know how to read that tcpdump output.

tcpdump "-vvv" doesn't give more information on these packets; at the same=
=20
time wireshark doesn't show anything suspicious except tons of wrong TCP=20
checksums caused (I hope...) by offloading.  I'll have to look if I can get=
=20
the raw traffic at the network switch to check this (but I think with 30%=20
and more wrong tcp checksums, traffic would completely break down so I'm=20
quite confident here.)


Slightly different topic: is there an NFS related mailing list I can=20
subscribe to?  This one is apparently closed for new subscribers, and the=20
bounce instructs me to send mail to majordomo-MogPR669STc76Z2rM5mHXA@public.gmane.org which=20
bounces :-(  Reading others' NFS postings might just give me more ideas on=
=20
where to look.


TODO today: play around with NFSv4 on the shaky assumption that nfsv3 is=20
actually working but net latency is killing my performance.


cheers
=2D- vbi



=2D-=20
The typewriting machine, when played with expression, is no more
annoying than the piano when played by a sister or near relation.
		-- Oscar Wilde

--nextPart2960845.esMhaXLicq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: get my key from http://fortytwo.ch/gpg/92082481

iKcEABECAGcFAkhgyblgGmh0dHA6Ly9mb3J0eXR3by5jaC9sZWdhbC9ncGcvZW1h
aWwuMjAwMjA4MjI/dmVyc2lvbj0xLjUmbWQ1c3VtPTVkZmY4NjhkMTE4NDMyNzYw
NzFiMjVlYjcwMDZkYTNlAAoJECqqZti935l6TjkAoIP5ysrdP3pNXT4leVCLPE0H
cTwOAJ9jgZT5E2QSnZoK9/Xc2NqvBWzJWw==
=yiNb
-----END PGP SIGNATURE-----

--nextPart2960845.esMhaXLicq--


--===============0565378231==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============0565378231==
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

--===============0565378231==--


