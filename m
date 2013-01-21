Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45566 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752543Ab3AUCtP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 20 Jan 2013 21:49:15 -0500
Date: Mon, 21 Jan 2013 13:48:59 +1100
From: NeilBrown <neilb@suse.de>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: NFSv4 cannot unmount ESTALE directories (in some cases).
Message-ID: <20130121134859.24fbd103@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/q_RJUD7sTZAO2to0Yf1LZG/"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/q_RJUD7sTZAO2to0Yf1LZG/
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


If you use NFSv4 to "mount server:/foo/bar /mnt", then "rm -r" /foo/bar on =
the
server, then accesses to /mnt will naturally return ESTALE.

Unfortunately "umount /mnt" will also return ESTALE and leave the stale
directory mounted.  Adding "-l" or "-f" to "umount" doesn't help.

The problem is that nfs_lookup_revalidate fails.  As the mountpoint is never
not accessed by a lookup (after the initial mount) it seems a bit pointless
calling d_revalidate in this case ... by maybe not.

I can make the problem go away by testing for LOOKUP_JUMP and having
nfs_lookup_revalidate never fail if that flag it set (for a directory).

The resulting patch is:
---
 fs/nfs/dir.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- linux-3.0-SLE11-SP2.orig/fs/nfs/dir.c
+++ linux-3.0-SLE11-SP2/fs/nfs/dir.c
@@ -1183,6 +1183,13 @@ out_zap_parent:
 			goto out_valid;
 		if (dentry->d_flags & DCACHE_DISCONNECTED)
 			goto out_valid;
+		if (flags & LOOKUP_JUMPED)
+			/* Didn't use a name to get here, so saying
+			 * the name is invalid is pointless.
+			 * This allows "umount" to succeed on a
+			 * STALE mountpoint.
+			 */
+			goto out_valid;
 		shrink_dcache_parent(dentry);
 	}
 	d_drop(dentry);


However I cannot easily tell if this is an elegant solution of an ugly hack,
and am hoping that someone who understands revalidation and LOOKUP_JUMPED
better than I (who only discovered the latter today) could provide advice.

Al?  Trond?  Should  I make this into a formal patch submission, or is there
a better way?

Thanks,
NeilBrown

--Sig_/q_RJUD7sTZAO2to0Yf1LZG/
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUPysmznsnt1WYoG5AQL6dxAAi9hMEX4FlvflqnPHGVI6Om7DZuY/u1nV
Gl2s7ZontRNEosysawSE0dfvlBANIdKQJdWDz2B8aslkl3sBONdUGENE3kS1cN7P
lGGFPKUIcR3y0m+6/mOecW6td4jf4gmd2Y8CPhoDGdz2BpUTCfOQhYU/8bgufp3S
g1Y4cGOKfRIBKFhuoevY17if3NsZNv+LjWUFE+sRT2QXPJslTi9Uf5L4Bv5okcFA
BsHZSsGUy9UaKwVbpDRZGpRf7DFmw63Mnk1FMbgPifAyzx2/2oC29Mmf91taOpzx
K6amtg+ex3oU0/JyfWEK0wsqt/vW3fh308eK/kGNY8MayPlrWIx47YGhGN1u5XPq
uuftGSQRa1V5ijYydOMa2hmojsfjU8fnY0Rssl8zsYwTqFWiOvxcVIIsb/XtLqy8
MqIO8zUGg34PB8doEomuJtCu/2R61FodADxkK+L2pEIlblhf0kRwuO+7RcEqSan3
JhTXv+zuhVFNTOszEfeXTZIYD9ijA1uKOHBbgBM79rbTGdMCdEvI12Ivau1k6e0B
IIvO00PFOSMgKf4HPW9uLHwxxTpGEcJTPuwBaZ31KOPnvyPxbsNBm3wWfRrkkbOk
F1AQlKp9jpRmwO6PcLC7C1ElEAaRywADvaS8HUZTmfQ8lc21YbXBH827qgpRLZuh
ugoVSokb/y4=
=bkos
-----END PGP SIGNATURE-----

--Sig_/q_RJUD7sTZAO2to0Yf1LZG/--
