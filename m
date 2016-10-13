Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38660 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751488AbcJMHZC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Oct 2016 03:25:02 -0400
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 13 Oct 2016 17:50:22 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH nfs-utils] nfs-server-generator: avoid using external services.
Message-ID: <8737k0215d.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


nfs-server-generator is run very early when a lot of services
are not yet started, so it mustn't depend on them.
Currently it can try to use hostname lookup and syslog.

Hostname-lookup is not needed, as we don't use the host issue,
and sending message to stderr is sufficient for the generator.

Disabling syslog is easy - call a function that sets a static variable.

Disabling hostname lookup isn't quite so easy, so add a static variable
which can be set to disable it.

Signed-off-by: NeilBrown <neilb@suse.com>
=2D--

hi,
 I contemplated passing another arg to export_read() and export_d_read()
 to resolve this, but it didn't seem worth it.

 Is this approach OK to people?

Thanks,
NeilBrown


 support/export/export.c        | 12 ++++++++++--
 support/include/exportfs.h     |  1 +
 systemd/nfs-server-generator.c |  4 ++++
 3 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/support/export/export.c b/support/export/export.c
index 0b8a858c2c74..c65dc8807a4e 100644
=2D-- a/support/export/export.c
+++ b/support/export/export.c
@@ -67,6 +67,14 @@ static void warn_duplicated_exports(nfs_export *exp, str=
uct exportent *eep)
 	}
 }
=20
+static int assume_canonical =3D 0;
+
+void
+export_avoid_host_lookup(int i)
+{
+	assume_canonical =3D i;
+}
+
 /**
  * export_read - read entries from /etc/exports
  * @fname: name of file to read from
@@ -83,9 +91,9 @@ export_read(char *fname)
=20
 	setexportent(fname, "r");
 	while ((eep =3D getexportent(0,1)) !=3D NULL) {
=2D		exp =3D export_lookup(eep->e_hostname, eep->e_path, 0);
+		exp =3D export_lookup(eep->e_hostname, eep->e_path, assume_canonical);
 		if (!exp) {
=2D			if (export_create(eep, 0))
+			if (export_create(eep, assume_canonical))
 				/* possible complaints already logged */
 				volumes++;
 		}
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index f033329b5fd2..ba45b2dee199 100644
=2D-- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -134,6 +134,7 @@ struct addrinfo *		client_resolve(const struct sockaddr=
 *sap);
 int 				client_member(const char *client,
 						const char *name);
=20
+void				export_avoid_host_lookup(int i);
 int				export_read(char *fname);
 int				export_d_read(const char *dname);
 void				export_reset(nfs_export *);
diff --git a/systemd/nfs-server-generator.c b/systemd/nfs-server-generator.c
index af8bb52bfbd7..7ae6dd1c4b20 100644
=2D-- a/systemd/nfs-server-generator.c
+++ b/systemd/nfs-server-generator.c
@@ -93,6 +93,10 @@ int main(int argc, char *argv[])
 	FILE		*f, *fstab;
 	struct mntent	*mnt;
=20
+	/* Avoid using any external services */
+	xlog_syslog(0);
+	export_avoid_host_lookup(1);
+
 	if (argc !=3D 4 || argv[1][0] !=3D '/') {
 		fprintf(stderr, "nfs-server-generator: create systemd dependencies for n=
fs-server\n");
 		fprintf(stderr, "Usage: normal-dir early-dir late-dir\n");
=2D-=20
2.10.0


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/y6uAAoJEDnsnt1WYoG5q5YP/075LHpVyO7cX6yVF/9SrQCo
Zs/090jieHaz1FzNSJkaMIHF5AWpXU7R7cwwUzR8GLSqtAhgo36a3KHJFrjNoL+E
4ow3uhN4lP5oeLRNUhWJEzDM0joDw8LBi6wosz1cV2MK5VhE4uXylyskYCkiW2UT
h4SJCq/ohP6mLzF56JGMk8wOSUOoPPSTbc7u/RvpR32Og94rrGr6rmSzIthyOtEd
vYjZ6kBV684ovlFBsxxnrkjb35HzQZFyTPkmVjW/40ejuFdSwcr8okZKfStX+VxK
xPW0iJYJktfJE8OiJQOkKqJnZnbS+ToqTbXfzFmT0/R+dxwW1thNH/9qxv+p0pKo
rJmSCSOZRxs7rpYrYmZhMcnbCL906JK5nNBUzAFhePaoftpq9QQmweolZGzeuQjy
bOc/lyzP6atC1Y8mqYq14DRdEkoIX3d+dmANINMMSY4PUBYWryhc3xCmo65ecUZY
3iy7K5tVtvNzgX3e1Z7TnM9F7nIPJRT+Sk0hvQZ3WLa4PZCzIAOh8sLZE8EAdcb0
I3bwRNNySKzJEf7UlB+7gvdDVEmPkowBHR5hw4z/aAqDx4WyVKZS0SqlLDpiO7YP
R1WcL5t1RYZIhqbhDcY4bq7UXtVCcUFPwCL3vfEW3mL8V5yv2ms7bDu8sTRf80Nd
kdKSTaKF3yRO0Q2Oxcd0
=TuXW
-----END PGP SIGNATURE-----
--=-=-=--
