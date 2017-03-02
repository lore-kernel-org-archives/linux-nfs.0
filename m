Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:59234 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751153AbdCBVZF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 16:25:05 -0500
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id BB754AB5D
        for <linux-nfs@vger.kernel.org>; Thu,  2 Mar 2017 21:24:57 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: linux-nfs@vger.kernel.org
Date: Fri, 03 Mar 2017 08:24:52 +1100
Subject: Confused by pnfs LAYOUTRETURN - seeking clarity.
Message-ID: <87shmvnzh7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


I've been trying to understand how LAYOUTRETURN is used in pNFS,
primarily because our SLE12-SP1 kernel (based on 3.12) appears
to have a very different opinion than some Netapp filers.

My reading of RFC-5661 suggests that the client needs to call
LAYOUTRETURN for every layout that it received from the server.  A
single LAYOUTRETURN can cover a whole file or a whole filesystem, so it
doesn't need to be 1-for-1, but there is no implicit return.

However RFC-5663 contains the text

   A LAYOUTRETURN operation represents an explicit release of resources
   by the client, usually done for the purpose of avoiding unnecessary
   CB_LAYOUTRECALL operations in the future.

This seems to imply that LAYOUTRETURN is only an optimisation.  If you
don't want to avoid CB_LAYOUTRECALL, there is not much call for
LAYOUTRETURN.  It seems to suggest (without explicitly saying) that the
CB_LAYOUTRECALL will effect the return of a layout without the client
explicitly sending LAYOUTRETURN in response.  RFC-5661 says LAYOUTRETURN
does need to be sent in response.

The code in 3.12 doesn't send LAYOUTRETURN in response to
CB_LAYOUTRECALL, nor does it send LAYOUTRETURN when it closes a file
marked as "return layouts on close".  The one place I have seen evidence
of it returning layouts is when a file is unlinked, though I think there
are others (chmod, IO error).

The current upstream code seems to call LAYOUTRETURN more correctly, but
it is hard to be sure because I couldn't find a commit which acknowledged
the specific problem and corrected it - just commits that claim to be
making improvements and avoiding races and things like that.

Questions:
 - Am I correct that all layouts need to be explicitly returned by the
   client, and so the text from RFC-5663 is misleading?

 - If so, what is the earliest kernel that is believed to correctly
   return layouts in response to CB_LAYOUTRECALL, or a 'roc' file being
   closed?


I was advised that Netapp are considering a change (netapp issue
955835):
  An enhancement will be added in future versions of Ontap to clear out
  the corresponding layout states after a file has been closed in the
  event the client does not return them.

This sounds like a mistake, unless "clear out" means "send
CB_LAYOUTRECALL for".  Should we advice Netapp against this?

Thanks,
NeilBrown


--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAli4jaQACgkQOeye3VZi
gbnVQRAAkswuVZw1eyE1wnYz2cPASxjR5mZ+2EyKHtJ84rQqVpinWpAU3m0/5LU1
yk0ExWsfuyy9rPEiJCuK2bYaw4/Ja62/wSTH433OwZSWZbnVCP6LYiEHaEj4FECN
BJ7pQf2n6Yk3Nd2N1RyA58uCfKblWZgVs/drLqZkUMmS5xRHINEEFuomopzYq76I
KKYuv8paW/Jc0JBou01YkA9Nptc6ZsJsPzFRfF2ys/Agr7ToYil0LZswThzlfJ2N
CTMYFUaJkrh+8ezE4cnXP1hViqSCk2RAxontnig2IKMjSHv77PK2xC/uCQ4tcfpk
8qsrzrBTwCF3727arQ8hU5aUlQrg+cKdyKaWpDJ17GuKfp7/fkNnxvM3YiMHw016
Rxt6QAVtWVDe9qPkO6WT0za0c8AQtA+tujFWxoN/Filjy9mkgJv4KL9xkwOobrdW
PfR9CMNn9O+8Hf+W3QuAbnHweFFCLbQomoBjx68/HqVPfklo1wxLnnwFmcKiE7dY
mzDG40vjPVsPqTEAbPeuoF0no1CDlPb1mbu/nG35FGRdpc+ZVAhgp/FEUbKkrIa5
UwFEGlgJSGu71KB7ex4IcDF+IOFfbg9ouROQiASQ9uaq3dmu1Lm2hp/FZc5X+6xq
nI8qF9ZP6cfYJVeo5xeiBU9xbnBW5iw0/+xGikUdOw5yCNAE2Eg=
=CE8Y
-----END PGP SIGNATURE-----
--=-=-=--
