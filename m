Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:42864 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602AbaCKAJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Mar 2014 20:09:19 -0400
Date: Tue, 11 Mar 2014 11:09:11 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/4 v2] nfsd: allow nfsv4leasetime and nfsv4gracetime to be
 set.
Message-ID: <20140311110911.4f1294ee@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ZIGLKH1WCALXrbyBWODW/q0"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/ZIGLKH1WCALXrbyBWODW/q0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



New arguments --gracetime (-G) and --leasetime (-L)

Signed-off-by: NeilBrown <neilb@suse.de>

--
resend of just patch 2 from the series with fix as discussed.
NeilBrown


diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index d44a5e7d6a5f..65e7b7193bda 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -46,6 +46,8 @@ static struct option longopts[] =3D
 	{ "debug", 0, 0, 'd' },
 	{ "syslog", 0, 0, 's' },
 	{ "rdma", 2, 0, 'R' },
+	{ "grace-time", 1, 0, 'G'},
+	{ "lease-time", 1, 0, 'L'},
 	{ NULL, 0, 0, 0 }
 };
=20
@@ -106,6 +108,8 @@ main(int argc, char **argv)
 	unsigned int protobits =3D NFSCTL_ALLBITS;
 	unsigned int proto4 =3D 0;
 	unsigned int proto6 =3D 0;
+	int grace =3D -1;
+	int lease =3D -1;
=20
 	progname =3D strdup(basename(argv[0]));
 	if (!progname) {
@@ -122,7 +126,7 @@ main(int argc, char **argv)
 	xlog_syslog(0);
 	xlog_stderr(1);
=20
-	while ((c =3D getopt_long(argc, argv, "dH:hN:V:p:P:sTUr", longopts, NULL)=
) !=3D EOF) {
+	while ((c =3D getopt_long(argc, argv, "dH:hN:V:p:P:sTUrG:L:", longopts, N=
ULL)) !=3D EOF) {
 		switch(c) {
 		case 'd':
 			xlog_config(D_ALL, 1);
@@ -221,6 +225,20 @@ main(int argc, char **argv)
 		case 'U':
 			NFSCTL_UDPUNSET(protobits);
 			break;
+		case 'G':
+			grace =3D strtol(optarg, &p, 0);
+			if (*p || grace <=3D 0) {
+				fprintf(stderr, "%s: Unrecognized grace time.\n", optarg);
+				exit(1);
+			}
+			break;
+		case 'L':
+			lease =3D strtol(optarg, &p, 0);
+			if (*p || grace <=3D 0) {
+				fprintf(stderr, "%s: Unrecognized lease time.\n", optarg);
+				exit(1);
+			}
+			break;
 		default:
 			fprintf(stderr, "Invalid argument: '%c'\n", c);
 		case 'h':
@@ -268,7 +286,7 @@ main(int argc, char **argv)
 	if (!found_one) {
 		xlog(L_ERROR, "no version specified");
 		exit(1);
-	}		=09
+	}
=20
 	if (NFSCTL_VERISSET(versbits, 4) &&
 	    !NFSCTL_TCPISSET(proto4) &&
@@ -292,12 +310,18 @@ main(int argc, char **argv)
 	}
=20
 	/*
-	 * must set versions before the fd's so that the right versions get
+	 * Must set versions before the fd's so that the right versions get
 	 * registered with rpcbind. Note that on older kernels w/o the right
 	 * interfaces, these are a no-op.
+	 * Timeouts must also be set before ports are created else we get
+	 * EBUSY.
 	 */
 	nfssvc_setvers(versbits, minorvers, minorversset);
-=20
+	if (grace > 0)
+		nfssvc_set_time("grace", grace);
+	if (lease  > 0)
+		nfssvc_set_time("lease", lease);
+
 	error =3D nfssvc_set_sockets(AF_INET, proto4, haddr, port);
 	if (!error)
 		socket_up =3D 1;
@@ -353,7 +377,10 @@ static void
 usage(const char *prog)
 {
 	fprintf(stderr, "Usage:\n"
-		"%s [-d|--debug] [-H hostname] [-p|-P|--port port] [-N|--no-nfs-version =
version] [-V|--nfs-version version] [-s|--syslog] [-T|--no-tcp] [-U|--no-ud=
p] [-r|--rdma=3D] nrservs\n",=20
+		"%s [-d|--debug] [-H hostname] [-p|-P|--port port]\n"
+		"     [-N|--no-nfs-version version] [-V|--nfs-version version]\n"
+		"     [-s|--syslog] [-T|--no-tcp] [-U|--no-udp] [-r|--rdma=3D]\n"
+		"     [-G|--gracetime secs] [-L|--leasetime secs] nrservs\n",
 		prog);
 	exit(2);
 }
diff --git a/utils/nfsd/nfsd.man b/utils/nfsd/nfsd.man
index aedf1409dc53..58b53cbff009 100644
--- a/utils/nfsd/nfsd.man
+++ b/utils/nfsd/nfsd.man
@@ -2,7 +2,7 @@
 .\" nfsd(8)
 .\"
 .\" Copyright (C) 1999 Olaf Kirch <okir@monad.swb.de>
-.TH rpc.nfsd 8 "7 Aug 2006"
+.TH rpc.nfsd 8 "20 Feb 2014"
 .SH NAME
 rpc.nfsd \- NFS server process
 .SH SYNOPSIS
@@ -83,6 +83,15 @@ offer certain versions of NFS. The current version of
 .B rpc.nfsd
 can support NFS versions 2,3,4 and the newer version 4.1.
 .TP
+.B \-L " or " \-\-lease-time seconds
+Set the lease-time used for NFSv4.  This corresponds to how often
+clients need to confirm their state with the server. Valid range is
+from 10 to 3600 seconds.
+.TP
+.B \-G " or " \-\-grace-time seconds
+Set the grace-time used for NFSv4.  New file open requests will not be
+allowed until after this time has passed to allow clients to recover state.
+.TP
 .I nproc
 specify the number of NFS server threads. By default, just one
 thread is started. However, for optimum performance several threads
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 4f2826b88905..eb21685ec135 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -303,6 +303,23 @@ nfssvc_set_rdmaport(const char *port)
 }
=20
 void
+nfssvc_set_time(const char *type, const int seconds)
+{
+	char pathbuf[40];
+	char nbuf[10];
+	int fd;
+
+	snprintf(pathbuf, sizeof(pathbuf), NFSD_FS_DIR "/nfsv4%stime", type);
+	snprintf(nbuf, sizeof(nbuf), "%d", seconds);
+	fd =3D open(pathbuf, O_WRONLY);
+	if (fd >=3D 0) {
+		if (write(fd, nbuf, strlen(nbuf)) !=3D (ssize_t)strlen(nbuf))
+			xlog(L_ERROR, "Unable to set nfsv4%stime: %m", type);
+		close(fd);
+	}
+}
+
+void
 nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers, unsigned int =
minorversset)
 {
 	int fd, n, off;
diff --git a/utils/nfsd/nfssvc.h b/utils/nfsd/nfssvc.h
index 5ea7a448019e..fbb89b22df20 100644
--- a/utils/nfsd/nfssvc.h
+++ b/utils/nfsd/nfssvc.h
@@ -24,6 +24,7 @@ void	nfssvc_mount_nfsdfs(char *progname);
 int	nfssvc_inuse(void);
 int	nfssvc_set_sockets(const int family, const unsigned int protobits,
 			   const char *host, const char *port);
+void	nfssvc_set_time(const char *type, const int seconds);
 int	nfssvc_set_rdmaport(const char *port);
 void	nfssvc_setvers(unsigned int ctlbits, unsigned int minorvers4, unsigne=
d int minorvers4set);
 int	nfssvc_threads(unsigned short port, int nrservs);

--Sig_/ZIGLKH1WCALXrbyBWODW/q0
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUx5UJznsnt1WYoG5AQLV5Q/+K3EIlo/vC6HS1E4+PwCAvKeL3AqGP8Zf
zVavSV40asXUZAZS6Xrm3WuGboHIU2uBUwGnrdDlF54XGv1YtLRbCgHJZBwzpbp6
Le20UT7+mfD3u2zIyRoAOIIGucyl7z2gnADfoAKvWZOJjX79u56k8nuMlBuMi6/5
ywPIkmtWtS8q9/MpqDmvjbCRsNOra3DI0ATl0afE4wBi3knTzJSVeSJNFHJQv+x5
vyA1k7ITyk3Xzn7GKIg9x2HLA6Oks4SUfw6HL6mY1dYNP1pyJkxK+cQKOTsqXSxd
+cm0nq3wD+lk+SWUBbfHjRrlUJEORhRBBL+Qc7dP3WHNWgPcfxQ7TJwrllObu4Np
kQlgYktrA0m1h1ZlfY7fjC+i4Kx1WpmmqG0o/EWiT95xJkaBcK4DOYJdTI2ZlMJf
DZRbc5GScd4FE7x6XUJ/brM3ptJlf5NfUkKxJJQA4NYj/w39MGCcOUAUpA4ldFFG
uWXceLpfJX0Tez+7UG55l9WswOoUrEp8K/D1Ps8d87aiuxoQErg2UHUPrt943T1T
qlbPNi2inBo37QpQ6sqfbifRauJc1DzdGzgROQCX7C+GGehd0lspRYFLeMr93fhL
rpBrV0pvA3/nnNzN3Thd/7SclyXbofC+ZWK58M2CWKka0UWZj90ovqOsCWi2rjHc
SzafZ1GhPs8=
=iSwv
-----END PGP SIGNATURE-----

--Sig_/ZIGLKH1WCALXrbyBWODW/q0--
