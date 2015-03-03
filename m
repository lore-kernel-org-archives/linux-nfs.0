Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.piware.de ([37.120.164.117]:43282 "EHLO mail.piware.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752406AbbCCKDB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Mar 2015 05:03:01 -0500
Date: Tue, 3 Mar 2015 10:55:16 +0100
From: Martin Pitt <martin.pitt@ubuntu.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] systemd: Order NFS server before client
Message-ID: <20150303095516.GB3219@piware.de>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="rJwd6BRFiFCcLxzm"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--rJwd6BRFiFCcLxzm
Content-Type: multipart/mixed; boundary="WIyZ46R2i8wDzkSu"
Content-Disposition: inline


--WIyZ46R2i8wDzkSu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello all,

I'm currently systemd-ifying our nfs-utils Ubuntu package. For testing
I put the NFS server and client (i. e. localhost:/foo/bar mounts) on
the same machine. With that I get long hangs during shutdown on
stopping the NFS .mount units, as when that happens the NFS server is
already shut down.

This is certainly a corner case as you'd usually not NFS-mount a share
=66rom localhost; but fixing it is relatively simple with the attached
patch which makes sure that if NFS server and client are installed,
the server starts before the client, and the client stops before the
server.

For a client without installed server this is harmless as Before=3D does
not imply a dependency. Likewise, for an NFS server which does not
mount shares by itself, it's also a no-op as remote-fs.target is
empty. This would only slightly reorder the boot sequence for machines
which both are an NFS server and have some remote NFS mounts, but
I don't see an issue with that.

Thanks for considering,

Martin
--=20
Martin Pitt                        | http://www.piware.de
Ubuntu Developer (www.ubuntu.com)  | Debian Developer  (www.debian.org)

--WIyZ46R2i8wDzkSu
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-systemd-Order-NFS-server-before-client.patch"
Content-Transfer-Encoding: quoted-printable

=46rom d8c1fcce6d06aa062315a47134e8e3b364cb0700 Mon Sep 17 00:00:00 2001
=46rom: Martin Pitt <martin.pitt@ubuntu.com>
Date: Tue, 3 Mar 2015 10:45:38 +0100
Subject: [PATCH] systemd: Order NFS server before client

This makes mounting NFS shares from localhost work reliably, as you need to
start the server before attempting (client) mounts, and conversely on shutd=
own
need to unmount all shares before stopping the server to avoid hangs.
---
 systemd/nfs-server.service | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/systemd/nfs-server.service b/systemd/nfs-server.service
index 8010aad..b35e193 100644
--- a/systemd/nfs-server.service
+++ b/systemd/nfs-server.service
@@ -13,6 +13,9 @@ Before=3D rpc-statd-notify.service
 Wants=3Dauth-rpcgss-module.service
 After=3Drpc-gssd.service gssproxy.service rpc-svcgssd.service
=20
+# start/stop server before/after client
+Before=3Dremote-fs-pre.target
+
 Wants=3Dnfs-config.service
 After=3Dnfs-config.service
=20
--=20
2.1.4


--WIyZ46R2i8wDzkSu--

--rJwd6BRFiFCcLxzm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCAAGBQJU9YUEAAoJENFO8V2v4RNHLXYQAMkwwqNNjIKSlRncF31Ih6UP
/JGc0z9KGew/4w7pzbs31pYqme/BtqowTbUh/tIeYzudbLtJKuYDhxjNseTciSfy
DsWl7goQwtbGdubeAaOjSD5iW7dKG8uatqOZ0l1oYiEhqKJj4hVzNFXfaJ86Jc2q
bW7vWidZh9DhIVvVSq/N+Zvo0ZRJ1nrMi6c1E3mAvRywXzFakWtXo+91mKV1yFLl
UDbZK8o2s4xNcR9lL6LotiLA2tihhtanQWf8yXXM18lz0Cn/q4u0gKQ2xcpk0qFq
fOE4MX9+Ij8FNF8sbKKOLQK1Gz+czroKgYY/7kclH+bt9pt/VvL/CAMeNFvBJped
TTHq88A72EJatxsNFlsMkn1pPy+P0L2fS0KADOmo+aTxpjff83F3DV0KWkAv/V18
awPxzwmwLBg7EPRFECsB5zyDJiNJOPPMjIxj9Apr4zmDdQ8x6k5OKJtXZIckA+rn
mFvZb786UX3Gjora/YfS3e9SPoJb/mJCTlQChBN0VuSst9l2QmRP/vZJzdTNWKbH
kOF34VFJFuXeTuvFeH0z/7Fsuu860a2gj+kiJCFHgoPvf6koTl/oymyavq7/dMqp
zfkUD78nYLJOteNsDU9wDtipOnCroTDBxTAgXJ+JMP6sD4PWp0DP2tOpIqaosuBz
ieIj9ys2q+sqAH0XKL/J
=d1Tj
-----END PGP SIGNATURE-----

--rJwd6BRFiFCcLxzm--
