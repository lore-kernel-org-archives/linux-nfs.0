Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59264 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751418AbdJFCsL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Oct 2017 22:48:11 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 06 Oct 2017 13:48:04 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [nfs-utils PATCH] Add RemainAfterExit to two services.
Message-ID: <877ew90z6j.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


Both auth-rpcgss-module and rpc-statd-notify only
ever need to be run once - the effect they have
is permanent.
We can give this information to systemd by setting
RemainAfterExit=3Dyes
This avoids the minor cost of running them a second time
if something "Wants" either service after it was first run,
(e.g. both client and server startup can Want these),
and avoids systemd complaining that it restarts to fast
if multiple Wants happen at nearly the same time.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 systemd/auth-rpcgss-module.service | 1 +
 systemd/rpc-statd-notify.service   | 1 +
 2 files changed, 2 insertions(+)

diff --git a/systemd/auth-rpcgss-module.service b/systemd/auth-rpcgss-modul=
e.service
index 5241f7b5d58e..4548283377d0 100644
=2D-- a/systemd/auth-rpcgss-module.service
+++ b/systemd/auth-rpcgss-module.service
@@ -14,3 +14,4 @@ ConditionPathExists=3D/etc/krb5.keytab
 [Service]
 Type=3Doneshot
 ExecStart=3D/sbin/modprobe -q auth_rpcgss
+RemainAfterExit=3Dyes
diff --git a/systemd/rpc-statd-notify.service b/systemd/rpc-statd-notify.se=
rvice
index 687fe31140c0..aad4c0d29efe 100644
=2D-- a/systemd/rpc-statd-notify.service
+++ b/systemd/rpc-statd-notify.service
@@ -13,3 +13,4 @@ PartOf=3Dnfs-utils.service
 [Service]
 Type=3Dforking
 ExecStart=3D-/usr/sbin/sm-notify
+RemainAfterExit=3Dyes
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlnW7uQACgkQOeye3VZi
gbmjYg//bWesKKhbf35Je4c/CZUvVqUWFKe0/JATnQzw+lrc8BU0gZxgtSd7Vp26
985YBT6VJYxBKTggmGM+bDxN0lzJoRH4EpzJph2w0/tgOocrz5qtUP6fOi2x5WTK
UF4s0g/AlCWeIw+KY/8MIoWoklqiBzxePZEBvunivC5N5IGEUAREGB4DUtavGXuH
48DIRMCzg76Di/VgZuSrLOI83OfhNmXaeaUaqD768csDMgu2JaufbIq00sRpu9qJ
kJtTtlqFjj0gddQgmpdRxFy3PZYCKNILTELjvX48CyLV2KV41KjDcUhVymJVnWIr
9mMx9m7qD9XAOCACGs8/dE0jmpVinI+K40g9VF0Sn3z4QVC2Klur0QuuKPrwakQa
4UR2nqxrlbcAFKeL3JepoWIRza7lIUsGEunxEa2NVqkYF0gEyS76JnZzVIH7yhdl
M+tLKx7/nMkA9OjCfEo0BL6Rl8lqR6qfebyq9WnbpJgVMekPZDllGKavu982kpRi
sjB1G5tvh7Q6MSCADxS4ntt85teAVxzMOPwLy/6tNH8QICBbYdzW13IdGXfqMSb3
HUas6d+yFINk9buVIZGqxJs6iP7TPqQKzRGb3cvHxHNAE9S01CLzJ+NAjRNBBYGi
/1gS2upDJbM4ybDW5a/lU9TG2U8APXEX7jXlvg9J9zFWNSNkfV4=
=rI0s
-----END PGP SIGNATURE-----
--=-=-=--
