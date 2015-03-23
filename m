Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40476 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924AbbCWFoD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Mar 2015 01:44:03 -0400
Date: Mon, 23 Mar 2015 16:44:14 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH - nfs-utils] mount: improve error message when statd cannot
 be started.
Message-ID: <20150323164414.7eca921f@notabene.brown>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/x2rVmNdmJFfNi=_sExeW3Ny"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/x2rVmNdmJFfNi=_sExeW3Ny
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



If you try to mount and NFSv3 filesystem, and statd is not running
and cannot be started (maybe rpcbind isn't running either), the
error message is:

  mount.nfs: rpc.statd is not running but is required for remote locking.
  mount.nfs: Either use '-o nolock' to keep locks local, or start statd.
  mount.nfs: an incorrect mount option was specified

That last line is incorrect and misleading: no incorret mount option was
specified.

This line comes from mount_error() in error.c.  In this case that
function doesn't really need to provide any more information.

So introduce a concention that EALREADY means an error message has
already been printed, and use it to suppress that message.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/mount/error.c b/utils/mount/error.c
index e06f598e96e3..c9797fc380c4 100644
--- a/utils/mount/error.c
+++ b/utils/mount/error.c
@@ -247,6 +247,9 @@ void mount_error(const char *spec, const char *mount_po=
int, int error)
 		nfs_error(_("%s: please report the error to" PACKAGE_BUGREPORT),
 				progname);
 		break;
+	case EALREADY:
+		/* Error message has already been provided */
+		break;
 	default:
 		nfs_error(_("%s: %s"),
 			progname, strerror(error));
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 76ecb3292860..df67facdd9d1 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -298,6 +298,7 @@ static int nfs_verify_lock_option(struct mount_options =
*options)
 			    "required for remote locking."), progname);
 		nfs_error(_("%s: Either use '-o nolock' to keep "
 			    "locks local, or start statd."), progname);
+		errno =3D EALREADY; /* Don't print further error message */
 		return 0;
 	}
=20

--Sig_/x2rVmNdmJFfNi=_sExeW3Ny
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUBVQ+oLjnsnt1WYoG5AQKqrg//SyIvXT1GoOqxc0AU+l+n+EWtaVj5lI+Y
hZO973E4j9LkSkl8bQujwCP4PHkkRBOZhkYfiMkxGK8mxdm+DqHMk2yhvf2kB7zQ
5bX5jvJdpXHdIgcKPVOFVQ7Yj/x0ZGBScTQcGHvdrVkdQI1VJqtbUunc85NIiaKx
s1Omx7un1tgr7G+5tMtO1c7X0PZkeVZ85EnuvsyKTmIVxGQkxW0QJMynBBxYFhbH
9ff4j0cmKNwWkqsiW3W8Y7s3ZN36CvZ4UJ92NmqQwRgGCatlxxRRAWFVWW83/N1X
JtBuFbiOl8MAVmUajhJ5o7DTlQ+BPY0jMDf741jzOUhypiAL6AL6peBINKSvQJS6
3wMCN6y23Jxx3aDbwN6AVe2j6Eq2lGgcmz9ZaT0mT7L0VRM3odUlUid9XgvfItrX
grLJ/uyZAleVKWYtfrxDwReNUPMy5v7T36LCYyB/0xly2pr26SlY/T98xRCaYEtY
EN9MW2dglb9evsXoiGN2j9pQhku9WjLHzIJuN4sbsOt2tFoA6tRTxC4d+Caf2ZB/
T4vnHMGlltYRMceUi4H3a18K1IB5d41vA97t9gIrTJ+GcS/m1TOIVR5omkTGO8dS
/QgHxiSkjn36ZWXd7043rzuoEd/XOGBeWvaBFK2wBHdAGblOU7dZ1co+fKQvx1Kj
LtcRVLVpgeQ=
=kngL
-----END PGP SIGNATURE-----

--Sig_/x2rVmNdmJFfNi=_sExeW3Ny--
