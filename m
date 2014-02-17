Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:52152 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753030AbaBQXnR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Feb 2014 18:43:17 -0500
Date: Tue, 18 Feb 2014 10:43:07 +1100
From: NeilBrown <neilb@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NFS <linux-nfs@vger.kernel.org>,
        Carsten Ziepke <kieltux@gmail.com>
Subject: [PATCH - nfs-utils] Fix fallback from tcp to udp
Message-ID: <20140218104307.34205fc8@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/YRw8ya6Hmt_zC.7HVV3yVeu"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/YRw8ya6Hmt_zC.7HVV3yVeu
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Protocol negotiation in mount.nfs does not correctly negotiate with a
server which only support NFSv3 and UDP.

When mount.nfs attempts an NFSv4 mount and fails with ECONNREFUSED
it does not fall back to NFSv3, as this is not recognised as a
"does not support NFSv4" error.
However ECONNREFUSED is a clear indication that the server doesn't
support TCP, and ipso facto does not support NFSv4.
So ECONNREFUSED should trigger a fallback from v4 to v2/3.

Once we allow that error, NFSv3 is attempted and mount.nfs talks to
rpcbind and discovers that UDP should be used for v3 and the mount
succeeds.

Signed-off-by: NeilBrown <neilb@suse.de>
Reported-by: Carsten Ziepke <kieltux@gmail.com>

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a642394d2f5a..6d4fd70b7b9e 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -807,6 +807,9 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
 		/* Linux servers prior to 2.6.25 may return
 		 * EPERM when NFS version 4 is not supported. */
 		goto fall_back;
+	case ECONNREFUSED:
+		/* UDP-Only servers won't support v4 */
+		goto fall_back;
 	default:
 		return result;
 	}

--Sig_/YRw8ya6Hmt_zC.7HVV3yVeu
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIVAwUBUwKeiznsnt1WYoG5AQJd+Q//cqNmR0x63rFBECZUgdtF/UO7hRPKekBx
kVc7fAiP3B42YlGTwWYnUWTQUNUsBXjQpybXXleuMW+mAlmxo7ka59t1wbUeIAI0
cmdk3JFI6Nm4+iPL3j8NkYBi13H9t4+UfDLfFfEgQGcz0U7zIL32mksWzRVpEhuQ
3tEHmtr2Wd6EfM2MCQb3AWMV8WIUjFefHNYjdVTSNl5KwPqRsFwQia4zHP+Pcdn9
HmMQNbxBcfbPI9uxdVM2Y45pAPIiEBCgH2kozdJaIqVFybU0pZqa6mfzozrZodzI
r5jamGp3xtJB1M5a431L2iP6kHIG0vBbohDT+Zkd/TJy1EwthwYTGUkvvOC1woQK
2dI7g2uUwtEypdzkKVk3Ze/tN+utdIM+CDbUv0rJD5myREihZ6YujaUJeTlrLcVx
YUe8f/RN8NB2RhBl8DyGBJlF0YT2xz2WeJGOKBfvHo34DOEUvsM6Nmk+qjcmDrWh
j7CRkxD8lmTa8TAMKFK3feZhYFEMJVqiT+rQxCcKJ22fVDaY7Yxf8e1de2PNf4/n
+sj0xIKi4P+TEgErQRO7vo2Qbcu3q+dOgs4z44oVwSlHBCQHjCLb1yuvIt0jkAq+
TruOdnmKFl+hC0bjEuAH7jKmtU7KDVlclnmDRwiXFSydLAWolFeinZURPauMyqYH
iFHdaf5pFHw=
=Rnqu
-----END PGP SIGNATURE-----

--Sig_/YRw8ya6Hmt_zC.7HVV3yVeu--
