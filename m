Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:42857 "EHLO
	prv3-mh.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003AbcDHAsH (ORCPT
	<rfc822;groupwise-linux-nfs@vger.kernel.org:0:0>);
	Thu, 7 Apr 2016 20:48:07 -0400
From: NeilBrown <nfbrown@novell.com>
To: Richard Laager <rlaager@wiktel.com>, trond.myklebust@primarydata.com,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Fri, 08 Apr 2016 10:47:46 +1000
Cc: linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: NFS Client Ignores TCP Resets
In-Reply-To: <57062C53.9080102@wiktel.com>
References: <56BFE55D.1010509@wiktel.com> <87twjjpcl8.fsf@notabene.neil.brown.name> <57062C53.9080102@wiktel.com>
Message-ID: <87wpo9lydp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Thu, Apr 07 2016, Richard Laager wrote:

>
> In a separate failover event, I tested accessing NFS over TCP. I do
> *not* get "Received RST segment.". So I conclude that
> tcp_validate_incoming() is not being called.

Thanks for all the details.  The ssh experiment quite convincingly shows
that the network infrastructure is working correctly.

The NFS experiment is strange - the RST doesn't even seem to be
arriving.  Yet the tcpdump shows that it did.

>
> Any thoughts on what that means or where to go from here?

Working back from tcp_validate_incoming, it is called from two places.
One is tcp_rcv_state_process() which handles connections which are not
currently established, so it should be irrelevant.
The other is tcp_rcv_stablished().
As the RST flag is set the fast-path branch will not be taken (as
->pred_flags cannot possibly contain RST) so it should reach the
slow_path: label.  The only things that can stop the code reaching
tcp_validate_incoming() is the "len" being less than 20 (which it isn't)
or the tcp checksum being wrong.
The tcpdump showed the checksum as '0', but that could be due to tcp
checksum offload.

You could add some printks in there (After slow_path:) to report when
tcp_checksum_complete_user() fails, particularly for th->rst packets.

Or you could try turning off tcp checksum offloading with
  ethtool  --offload rx off DEVICENAME
(I think).

It might help to see a tcpdump trace of the case where the "ssh"
connection was broken successfully for comparison with the case where
the nfs connection wasn't broken.  Or it might not.

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXBv+zAAoJEDnsnt1WYoG5IzQP/0o7sAXAoJHW1JH+0z8m6z1Q
6CDTP9kVIEXyHoMnK0BVusBqUh3/ENwMmTUYntNnCQ+2dGLFkvDVd+sAJ8UlfhRk
T03aJpoCQhizeCixqsK+nTYgWkFQ4xw6OSgnBkCM37yOkCm8VNdUzRWAfb/gE54G
sNAuSOOjxy6V4frKRQtVN/8V/8fhNOV3FICGoYm4hAbBZuJYlTbCTQ+S/CaSUGsn
xp6sEJboGQ5LJR9s+EYChBDal/Tgoxd8Vb39PAPdZCE6alVU5Xrnpsek9bGVoH1T
ciaRbBWOu1BfXxQvXCSKs88Fxty7aEHpCHzpgE1gRf9P92iHRwJsmPFPrsCSHTiZ
rO8kF+IjMRpD0Iu2qYcWMnXTac4bJMi94Di9TBj2yMu0qOPGB+YDz0oNZ8bPoz+C
gKLzhefo6pC14b9ZnshYFWaCEAD3hZ7sKhgqxKHn3BesNi9LAfL5+/BC+KS30JVI
WgYKcW9PARldTGHtgIL2Gj/ZBpHX2rvbV48nBbNuQYWvSNwx1vpnVkkGRuolgVvA
j8ylqfZ1Mwx/4No7mgy/9DyRJZlh+wwQoNE3o23jDk3uQOf8MU803nkzGAEKynI2
IBb15FBQ0l/7fuWhj48SFKPgcJU0QMnxN3PwRjxcc/ej7AzwkZI6KlWEU/uwDYAH
9GSEGnQpkUdbpjki50BN
=bydY
-----END PGP SIGNATURE-----
--=-=-=--
