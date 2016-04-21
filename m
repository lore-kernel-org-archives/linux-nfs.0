Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:49302 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760AbcDUX3r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Apr 2016 19:29:47 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Fri, 22 Apr 2016 09:29:39 +1000
Subject: [PATCH/nfs-utils] mount: run START_STATD fully as root
cc: NFS List <linux-nfs@vger.kernel.org>
Message-ID: <87shyey1zw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


If a "user" mount is the first NFSv3 mount, mount.nfs will be running
setuid to root (with non-root as the real-uid) when it executes START_STATD.

start-statd is a shell script and many shells refuse to run setuid,
dropping privileges immediately.  This results in start-statd running
as an unprivileged user and so statd fails to start.

To fix this, call "setuid(0)" to set real uid to zero.  Also call "setgid(0)"
for consistency.

The behaviour of a shell can often be affected by the environment,
such as the "shell functions" that bash includes from the environment.
To avoid the user being able to pass such environment to the shell,
explicitly pass an empty environment.  The start-statd script explicitly
sets the PATH which is all it really needs.

Signed-off-by: NeilBrown <neilb@suse.com>

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 7240ca7bcdc4..0d12613e86a4 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -795,6 +795,7 @@ int start_statd(void)
 		if (S_ISREG(stb.st_mode) && (stb.st_mode & S_IXUSR)) {
 			int cnt = STATD_TIMEOUT * 10;
 			int status = 0;
+			char * const envp[1] = { NULL };
 			const struct timespec ts = {
 				.tv_sec = 0,
 				.tv_nsec = 100000000,
@@ -802,7 +803,9 @@ int start_statd(void)
 			pid_t pid = fork();
 			switch (pid) {
 			case 0: /* child */
-				execl(START_STATD, START_STATD, NULL);
+				setgid(0);
+				setuid(0);
+				execle(START_STATD, START_STATD, NULL, envp);
 				exit(1);
 			case -1: /* error */
 				nfs_error(_("%s: fork failed: %s"),

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXGWJjAAoJEDnsnt1WYoG59GUQALRwmGTIWm0wUYf2XqTdBXky
P8dYJIYbOl9EJbPdar3txnwsUOpcDKl2Uwl3TVMJ6QB6HOxY5k5Gge7FU9FRylf5
eo28SWMlUDLx/vALcEytrZwqcBHzQmlpedhcDXwg83BHbwyj7kctdUvQn7Q3vGF3
MddvN6OdKp1nPMzRdj7Yi5EGkPGIScELbPGRROgO73oDxbaOJ7Fl/lUPGzHJNX1f
b/cTGh7gDquKo6zuu0LXmmXBSxsOBtHloAU2Vub8QKscBelsRIxiQKnZnH5gANXe
2hudzOCTDKKsL7/yEzeSa9kWeKkhPJMBpRnr6hV3tUBdoVrjOqK0ns/e75aBgonj
DicZgGkk0yTeEqOVdcRWCe9YXDRfvvIWoJu8djh+oYUY/eBnKtSXKqpYBNIhMeZj
TdS68lEoQPzc4l9bIo44eMNN5slQbt5YmKcY85Y3mdxzMws0Q+lcX0Ty0gaHC+qe
DGQQ6VIw4hMiKnOtCvHKVU/yaQLPPcAxvNp1TTJf86uymyHrkWxcTZ5HhJ2s69qv
y2lN/DfUJyjn/hfkhfg8USkAgq1Khr+cTKDNzVNrcSzKWptS31CtS3c6BtV3X9rK
55iCO4Z6fnjzAKY1qHue5gGACG2vi+YbaJOCQWDAnyJ1FfFIfrLEmQjs7ITbiYWS
YurlP01Ir8IQY2jydenX
=PRLx
-----END PGP SIGNATURE-----
--=-=-=--
