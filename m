Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:53976 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750864AbdE2WTZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 May 2017 18:19:25 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@RedHat.com>
Date: Tue, 30 May 2017 08:19:16 +1000
Cc: systemd-devel@freedesktop.org, linux-nfs@vger.kernel.org
Subject: [PATCH] nfs.man: document incompatibility between "bg" option and systemd.
In-Reply-To: <20170529133814.GC17967@gardel-login>
References: <87lgpkgwrw.fsf@notabene.neil.brown.name> <20170529133814.GC17967@gardel-login>
cc: Lennart Poettering <lennart@poettering.net>
Message-ID: <87tw43fgrf.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Systemd does not, and will not, support "bg" correctly.
It has other, better, ways to handle "background" mounting.

Explain this.

See also https://github.com/systemd/systemd/issues/6046

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 utils/mount/nfs.man | 18 +++++++++++++++++-
 1 file changed, 17 insertions(+), 1 deletion(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index cc6e992ed807..7e76492d454f 100644
=2D-- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -372,6 +372,21 @@ Alternatively these issues can be addressed
 using an automounter (refer to
 .BR automount (8)
 for details).
+.IP
+When
+.B systemd
+is used to mount the filesystems listed in
+.IR /etc/fstab ,
+the
+.B bg
+option is not supported, and may be stripped from the option list.
+Similar functionality can be achieved by providing the
+.B x-system.automount
+option.  This will cause
+.B systemd
+to attempt to mount the filesystem when the mountpoint is first
+accessed, rather than during system boot.  The mount still happens in
+the "background", though in a different way.
 .TP 1.5i
 .BR rdirplus " / " nordirplus
 Selects whether to use NFS v3 or v4 READDIRPLUS requests.
@@ -1810,7 +1825,8 @@ such as security negotiation, server referrals, and n=
amed attributes.
 .BR rpc.idmapd (8),
 .BR rpc.gssd (8),
 .BR rpc.svcgssd (8),
=2D.BR kerberos (1)
+.BR kerberos (1),
+.BR systemd.mount (5) .
 .sp
 RFC 768 for the UDP specification.
 .br
=2D-=20
2.12.2


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlksnmYACgkQOeye3VZi
gblvlxAAnu+c6MM+0l7PzszEnZPwIpKjnThp4ix2Cdauq1X4SXYc9E5Uu/vtivR8
j7AH+WWKr+9vnPzc4FpnlsLnmjdlrHADFQkMjskY60fAKxyW0iTZIRMvjlpRzq8v
moetaO4Twq0UZkmtSaiRIDALgML+sFDspc5hCduUhBpgVKPQXYZKJsSCSqeNdowR
rWJu1DE4Gl8nFYJwSDPLO2yTzUhLu2A+R2pS8rQlAOaR2+N+lfDlxbdahDvoyN3L
k0YG0uBG4mPg8HdcfZkDcrWDAR8ptjvGU4AOtn0QHBuAYVxc+vcIgGvyNmo00D5U
TX3Ofp37cgcdrhR+OnAUj0YoTR9dbLgUSa4lkBX/BqiP8COkO7kBJ7R1NsN8urcA
78T6vl+dwzb5Nb+UJq37ZX7mgzbQoLUlRWdm01CWQ6howgu8vpfBgXAhzbWj1gHT
j5vNhjyee9mhHB8X7OpT4SGkL4+fXUnjRSe0RQUrIYwiR2oxBLwvB4YdW/QArSoH
Rw5GZhfesqkBBl3ADXT7Hj3nGgYdcKVGWBOpkPRN0lS7jnAE4S74GxcD6w7wuvUc
WLo/7gGTOrLH3eoBBWJXAPnB/vDnJ86okhxOf9aWr1Ez3tzzSFrNNIROIsTtsDjm
dv1cHLC9Fp/8VM8cPl9oq9KSSDOtTbhl5Jx05BUxLUpNRznlLxQ=
=54bQ
-----END PGP SIGNATURE-----
--=-=-=--
