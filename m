Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:37789 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750749AbdLMETY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 12 Dec 2017 23:19:24 -0500
From: NeilBrown <neilb@suse.com>
To: "Michael Kerrisk \(man-pages\)" <mtk.manpages@gmail.com>
Date: Wed, 13 Dec 2017 15:19:14 +1100
Cc: linux-man@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: [PATCH] fcntl.2, read.2, write.2: document "Lost locks" as cause for EIO.
Message-ID: <87lgi7nttp.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


If an advisory lock is lost, then read/write requests on any
affected file descriptor can return EIO - for NFSv4 at least.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--
 man2/fcntl.2 | 24 ++++++++++++++++++++++++
 man2/read.2  |  9 +++++++++
 man2/write.2 |  9 +++++++++
 3 files changed, 42 insertions(+)

diff --git a/man2/fcntl.2 b/man2/fcntl.2
index 67642384154c..6e6e26f66aa0 100644
=2D-- a/man2/fcntl.2
+++ b/man2/fcntl.2
@@ -669,6 +669,30 @@ and
 Mandatory locking is not specified by POSIX.
 Some other systems also support mandatory locking,
 although the details of how to enable it vary across systems.
+.SS Lost locks
+When an advisory lock is obtained on a networked filesystem such as
+NFS it is possible that the lock might get lost.
+This may happen due to administrative action on the server, or due to a
+network partition which lasts long enough for the server to assume
+that the client is no longer functioning.
+.PP
+When the filesystem determines that a lock has been lost, future
+.BR read (2)
+or
+.BR write (2)
+requests may fail with the error
+.BR EIO .
+This error will persist until the lock is removed or the file
+descriptor is closed.
+Since Linux 3.12,
+.\" commit ef1820f9be27b6ad158f433ab38002ab8131db4d
+this happens at least for NFSv4 including all minor versions.
+.PP
+Some versions of Unix send a signal
+.RB ( SIGLOST )
+in this circumstance.
+Linux does not define this signal, and does not provide any
+asynchronous notification of lost locks.
 .SS Managing signals
 .BR F_GETOWN ,
 .BR F_SETOWN ,
diff --git a/man2/read.2 b/man2/read.2
index f2e1379865df..0fea86e523a5 100644
=2D-- a/man2/read.2
+++ b/man2/read.2
@@ -163,6 +163,15 @@ or its process group
 is orphaned.
 It may also occur when there is a low-level I/O error
 while reading from a disk or tape.
+A further possible cause of
+.B EIO
+on networked filesystems is when an advisory lock had been taken
+out on the file descriptor and this lock has been lost.
+See the
+.I "Lost locks"
+section of
+.BR fcntl (2)
+for further details.
 .TP
 .B EISDIR
 .I fd
diff --git a/man2/write.2 b/man2/write.2
index 796cae8ba221..621a484dc3a2 100644
=2D-- a/man2/write.2
+++ b/man2/write.2
@@ -197,6 +197,15 @@ be reported by a subsequent
 (whether or not they were also reported by
 .BR write (2)).
 .\" commit 088737f44bbf6378745f5b57b035e57ee3dc4750
+An alternate cause of
+.B EIO
+on networked filesystems is when an advisory lock had been taken out
+on the file descriptor and this lock has been lost.
+See the
+.I "Lost locks"
+section of
+.BR fcntl (2)
+for further details.
 .TP
 .B ENOSPC
 The device containing the file referred to by
=2D-=20
2.14.0.rc0.dirty


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlowqkMACgkQOeye3VZi
gbmpwA//RkYX2uZhbAEmr5+lmS0WihHY4CRVUwhMDWUL06xLiyC+ufheOG1hBdhO
gx9P3kkpIkNikoFoAM//oTIhEhxulTcx+bSBpXnP3sfKKxJE/5VrveN71ZuQEckX
Do8Jd6K74Xb4m9BWRxwB8Dr9F++7UipCosSQ9G9ygrLWHwxI0c2EE2qVEye7faU/
o6DIYhzd0Gw2cUBCAruH2Lms+Lrxsfksn+2/9zBE/adrpfsVBdX49AyHpeP+S3kZ
GOmx4sHMk5qSg3aQ3L0kvOis9hdqLAmHXIrDSa6XDqYuqbflXFXoTifa+dTMJdp5
x/t6nawNZwcYHpjcVog2ym7VqmeynYw7rGzBvQZX1tRZsEhRkqsLAH4Al+h0sSAP
GCqbBktNx4KB7AGCpLo0akUwLmT6MsHe1rUD8l/UAEC0y3tfvCTf3bLrZAIXDdMA
gL5PQJumSD4uqilpUo8mHiQAYVox1pRHG1hbW+uyP+GeaJS616fvtkvMza8OdN3O
ZAHWOO2L/StdLk8pJQyC13LXukTf/LMJFGLgDWOpMArp3iL93HUxZYBuvPuDaMlq
AXq36q1KOQZ038Y4edd77XQMQB0DI75/mRNJ9Hb2T+ZBfobfDAb/M2/ruxZbaokn
WnCLgYsDE8kGa6eRLej3daLfxRV8Z5HsLYbau8LJGdTTRUCf75I=
=JsbZ
-----END PGP SIGNATURE-----
--=-=-=--
