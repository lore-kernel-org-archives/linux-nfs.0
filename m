Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39131 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750718AbcFVE1j (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Jun 2016 00:27:39 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 22 Jun 2016 14:27:24 +1000
Cc: Howard Guo <hguo@suse.com>
Subject: [PATCH] nfs.man: clarify effect of 'retry' option.
cc: NFS List <linux-nfs@vger.kernel.org>
Message-ID: <87por9lufn.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain



The total timeout for a "mount" attempt to an non-responsive server
will always be a multiple of time a single mount attempt in the kernel takes,
which for TCP defaults to about 4 minutes.
The documentation for the "retry" option seems to suggest that this can be used
to set a maximum but it really sets a time after which to stop retrying.
The total can be as much as "retry" plus the time for a single attempt.

So clarify the documentation a bit, and also note that retrans
defaults are different for UDP and TCP:
   #define NFS_DEF_UDP_RETRANS	(3)
   #define NFS_DEF_TCP_RETRANS	(2)

Reported-by: Howard Guo<hguo@suse.com>
Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index e541cdc95cb1..fab24f898f64 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -391,6 +391,13 @@ is 2 minutes, and the default value for background mounts is 10000 minutes
 If a value of zero is specified, the
 .BR mount (8)
 command exits immediately after the first failure.
+.IP
+Note that the total timeout will always be a multiple of the time
+determined by the
+.BR timeo
+and
+.BR retrans
+options, which by default will be 30 minutes.
 .TP 1.5i
 .BI sec= flavors
 A colon-separated list of one or more security flavors to use for accessing

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXahOtAAoJEDnsnt1WYoG5TYEP/i6A3lqRocKI59uSVeImL/z9
U2B9uhDPftrQT/EQHjnFIDAVzp4bH18WH0315uNGzeR3ZlC09cHFkgxU4dsSZndl
1syRSfpYxGMTfn/EBmwDWb3MlDTYeuQvQLCcvucvdKMqqmv7qJlqTTJkgQcDMFsl
3YiDZhRM2tzrDTK0I2EQah2xriYwfDnmB+n1eMfzEnIIjCUM0R/6cy3z+GuODpe4
kFnLolSdYDm29YTRWmUD2ldHMUJw9H6J8V4WtDFFEUDwFfFsIatZjrtihHPi+u/p
n8vrtpWv/4hWkctmUa9kYfIcjKX5SOu8OVg3jnOHgqMGFOmbs6KVkGdrMMUceOG2
uU5f9hlmS5mrCl27c/94ILvW9NRVLNrst17ydYBBPpkW0ihQ8ELEEMaOQucEzxAI
2nTGs51bZv90/yWK+eHpvy0L+e1ApvqcmiilaPBqlvRb8vP1ZflrMsfotVVOIuA0
ymLXhVlQ652IIitpV0ad5rLviFefbSvKIqW3+DCPD44HhOsHqXbwNeMOfBFBzwuw
zlfnsFvDCY3u+W7u7E/AgI+tb3+9EL7rrnD6K/kAeHRv55iZlPRI/RnI7zHVlpPb
U3NIwxaBzb4TJ3tDY5nFYwDMvlJ+yGyEJirdZIlWOn9vutZr4kNKeb1t5n2j/AiS
PbWK1uD7lwOsBoc3cHK5
=AbhR
-----END PGP SIGNATURE-----
--=-=-=--
