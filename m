Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:54365 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751394Ab3KNBHY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Nov 2013 20:07:24 -0500
Date: Thu, 14 Nov 2013 12:07:11 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Charles Edward Lever <chuck.lever@oracle.com>,
        "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: [PATCH - nfs-utils] gssd: always reply to rpc-pipe requests from
 kernel.
Message-ID: <20131114120711.4043a60f@notabene.brown>
In-Reply-To: <1384306012.15992.9.camel@leira.trondhjem.org>
References: <1384037221-7224-1-git-send-email-steved@redhat.com>
	<E061C7A8-DC27-49BA-93C2-DC2E9C19EA7B@netapp.com>
	<52811CBB.3070204@RedHat.com>
	<E520DD5F-7E5A-4B6C-9FF6-6B74DA36FD1E@oracle.com>
	<5281290B.6000201@RedHat.com>
	<E0FBCF46-C70F-41E5-BA67-48406253CD7E@oracle.com>
	<20131112161135.25a487da@notabene.brown>
	<F58540AB-00BE-4AC5-B823-7260F30F8D58@netapp.com>
	<20131112161634.GC15060@fieldses.org>
	<20131113112346.3f5f3bd0@notabene.brown>
	<1384302651.15992.3.camel@leira.trondhjem.org>
	<20131113121333.2a16f646@notabene.brown>
	<1384306012.15992.9.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/_dipBElgB5vm1+R6HXsr8HA"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/_dipBElgB5vm1+R6HXsr8HA
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Sometimes gssd will open a new rpc-pipe but never read requests from it
or reply to them.  This causes the kernel to wait forever for a reply.

In particular, if a filesystem is mounted by IP, and the IP has no
hostname recorded in /etc/hosts or DNS, then gssd will not listen to
requests and the mount will hang indefinitely.

The comment in process_clnt_dir() for the "fail_keep_client:" branch
suggests that it is for the case where we couldn't open some
subdirectories.  However it is currently also taken if reverse DNS
lookup fails (as well as some other lookup failures).  Those failures
should not be treated the same as failure-to-open directories.

So this patch causes a failure from read_service_info() to *not* be
reported by process_clnt_dir_files.  This ensures that insert_clnt_poll()
will be called and requests will be handled.

In handle_gssd_upcall, the current error path (taken when the mech is
not "krb5") does not reply to the upcall.  This is wrong.  A reply is
always appropriate.  The only replies which aren't treated as
transient errors are EACCES and EKEYEXPIRED, so we return the former.

If read_service_info() fails then ->servicename will be NULL which will
cause process_krb5_upcall() (quite reasonably) to become confused.  So
in that case we don't even try to process the up-call but just reply
with EACCES.

As clp->servicename=3D=3DNULL is no longer treated as fatal, it is not
appropraite to use it to test if read_service_info() has been already
called on a client.  Instread test clp->prog.

Finally, the error path of read_service_info() will close 'fd' if it
isn't -1, so when we close it, we should set fd to -1.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index b48d1637cd36..58c2a282524f 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -256,6 +256,7 @@ read_service_info(char *info_file_name, char **servicen=
ame, char **servername,
 	if ((nbytes =3D read(fd, buf, INFOBUFLEN)) =3D=3D -1)
 		goto fail;
 	close(fd);
+	fd =3D -1;
 	buf[nbytes] =3D '\0';
=20
 	numfields =3D sscanf(buf,"RPC server: %127s\n"
@@ -403,11 +404,10 @@ process_clnt_dir_files(struct clnt_info * clp)
 		return -1;
 	snprintf(info_file_name, sizeof(info_file_name), "%s/info",
 			clp->dirname);
-	if ((clp->servicename =3D=3D NULL) &&
-	     read_service_info(info_file_name, &clp->servicename,
-				&clp->servername, &clp->prog, &clp->vers,
-				&clp->protocol, (struct sockaddr *) &clp->addr))
-		return -1;
+	if (clp->prog =3D=3D 0)
+		read_service_info(info_file_name, &clp->servicename,
+				  &clp->servername, &clp->prog, &clp->vers,
+				  &clp->protocol, (struct sockaddr *) &clp->addr);
 	return 0;
 }
=20
@@ -1320,11 +1320,14 @@ handle_gssd_upcall(struct clnt_info *clp)
 		}
 	}
=20
-	if (strcmp(mech, "krb5") =3D=3D 0)
+	if (strcmp(mech, "krb5") =3D=3D 0 && clp->servername)
 		process_krb5_upcall(clp, uid, clp->gssd_fd, target, service);
-	else
-		printerr(0, "WARNING: handle_gssd_upcall: "
-			    "received unknown gss mech '%s'\n", mech);
+	else {
+		if (clp->servername)
+			printerr(0, "WARNING: handle_gssd_upcall: "
+				 "received unknown gss mech '%s'\n", mech);
+		do_error_downcall(clp->gssd_fd, uid, -EACCES);
+	}
=20
 out:
 	free(lbuf);

--Sig_/_dipBElgB5vm1+R6HXsr8HA
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUoQiPznsnt1WYoG5AQJXuhAAjOBcQwmVfsrVfaTR8p1lh/8LQHIU7Cff
STo8UJM0UKZxnX5u/ymlS3QyK78NLJ9OGWACEl2/4GQr/2jPzbFPANSHKzuh8d2g
aj07z//d/dv8Gue0LNDdnEweRGz7ti0tBbb6xBnpJSnXbFqAPTl8Uz62KT7eJUw7
VMRfQ/cJpcfhIg3FyozNM+QepsZQdM1KFg61/63Lk8EtT3dshpZRnahnUX2DuLOs
05hq7VNRXzME0BcVHxj5HxeTfs8ufLOd/hr2z/aaL/MgIZ25UD/6m7+QByHT0B1x
T1gTM0SMp909gDNkxHfjIvr5Efz+q0LZs4+/ZddQ10mW27QHtotdO1vYGP5SsoHc
gmklLDNzrRhw8NlOburfCUI1BwuVvgHqmqEt6u99eXDcjgx+5DiMO63SzRgs0jic
x2Ry8bAKGAq7oeh4Fdda6Bnx5864O8I8Ass9uTwPGmaql2imW7PSih1OPkHRhVUF
yapEnXOMJBk+CiSJ85a1QSL/u9ZJ/oy87kA+9yie3t3OSvEnmKr6tI6PEiUoFEBq
tqciqaOG2+1eksHE3r9vpjUVN8UlAraai10+/uE3pi0VY4VT24uFXIN92SWCgoqP
LwUx/m64QjADYnEQ7siPBMfxjzVYtypdp0sgCeqp68jaW5ih1+cvororJ2X2xVfX
gUwUxIZoi5M=
=2Oxx
-----END PGP SIGNATURE-----

--Sig_/_dipBElgB5vm1+R6HXsr8HA--
