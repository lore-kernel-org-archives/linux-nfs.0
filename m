Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38510 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932114Ab3CDV5K (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Mar 2013 16:57:10 -0500
Date: Tue, 5 Mar 2013 08:57:00 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [PATCH - nfs-utils] gssd: don't krb5_free_context if
 krb5_init_context fails
Message-ID: <20130305085700.56921777@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/LV775wLNyx2rFrl+BeLHV_D"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/LV775wLNyx2rFrl+BeLHV_D
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Most places that call krb5_init_context() abort cleanly on failure.
However these two then try to free the non-existent context, which
doesn't end well.

Signed-off-by: NeilBrown <neilb@suse.de>

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index aeb8f70..4befa72 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1212,9 +1212,9 @@ gssd_destroy_krb5_machine_creds(void)
 				    "cache '%s'\n", k5err, ple->ccname);
 		}
 	}
+	krb5_free_context(context);
   out:
 	free(k5err);
-	krb5_free_context(context);
 }
=20
 /*
@@ -1257,7 +1257,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 		k5err =3D gssd_k5_err_msg(context, code);
 		printerr(0, "ERROR: %s: %s while resolving keytab '%s'\n",
 			 __func__, k5err, keytabfile);
-		goto out;
+		goto out_free_context;
 	}
=20
 	if (ple =3D=3D NULL) {
@@ -1272,7 +1272,7 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 				 "in keytab %s for connection with host %s\n",
 				 __FUNCTION__, keytabfile, hostname);
 			retval =3D code;
-			goto out;
+			goto out_free_kt;
 		}
=20
 		ple =3D get_ple_by_princ(context, kte.principal);
@@ -1288,14 +1288,15 @@ gssd_refresh_krb5_machine_credential(char *hostname,
 				 __FUNCTION__, pname ? pname : "<unparsable>",
 				 hostname);
 			if (pname) k5_free_unparsed_name(context, pname);
-			goto out;
+			goto out_free_kt;
 		}
 	}
 	retval =3D gssd_get_single_krb5_cred(context, kt, ple, 0);
-out:
-	if (kt)
-		krb5_kt_close(context, kt);
+out_free_kt:
+	krb5_kt_close(context, kt);
+out_free_context:
 	krb5_free_context(context);
+out:
 	free(k5err);
 	return retval;
 }

--Sig_/LV775wLNyx2rFrl+BeLHV_D
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUTUYrDnsnt1WYoG5AQKImA/9HZ237X2D1zKvJ5/1IsocnFU6bGFg7bzE
uE46sjllYKAQ77ze2xUSSvxD1XbCEUg4mBxV9+HgGIoz2PNmg5TYWaRmhVZKyXV1
ScJsxbuZesSo+wkhMggBYtxTim+FwB2bssgojR/OZ3ZeWVRzuip32DNUPbO2HX8D
JsN612WeBh+zug2ig2SLf5k/NnmdGXqDonmfCH4BkkX8RvEOQXrKW+3ddY7Ib/uo
ycTJ5UTYmvUhw3kSQVHOg74icDik56EkBkHPd1A8XI1qKh1q13YK+FNEyhkYs2R4
AEwrYlxnkO51L9SWynB7PVIut0avYOpT0Bycq4DD+fbGPRXmNM2CenDBGi6tJHMZ
NlSTt9Dsr6A1Xl6BnnBkI8jIc+9YoSDcvBTNCA7rdvtwXOuFz6TgnVtkfGedKI84
9emY9cyVwLjlfxFBru49bNFIxMwXudV4D0fVvsLVSz75sHGT21xQ1KH8J7PzMA2n
DkgVcAI+KbywysfZQWfD0RvOl7UQgrCVI+x6XBMNvQ5WUUN9oEZ3/6iO8CVMPzYi
wCcvdp0bxVW5hvawDRw4d60g0MXWgRU/QR/TgUUH47lkLBrIk6UkvjmWCzXANDie
8sUAVVTpi0utOxRdJAeuQ8GwH2PWuJBW11uKtolMelQIGFwEupme4dUz0IFu7bbc
+LDLYgl2WZM=
=FfWN
-----END PGP SIGNATURE-----

--Sig_/LV775wLNyx2rFrl+BeLHV_D--
