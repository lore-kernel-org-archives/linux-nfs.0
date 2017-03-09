Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44235 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750713AbdCIDiW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 22:38:22 -0500
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id C271BAAA3
        for <linux-nfs@vger.kernel.org>; Thu,  9 Mar 2017 03:37:01 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: "Linux NFS" <linux-nfs@vger.kernel.org>
Date: Thu, 09 Mar 2017 14:36:55 +1100
Subject: A NFS mount can still write to the server after 'umount' has completed.
Message-ID: <871su7i0iw.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


I've been chasing down a problem where a customer has a localhost mount,
and the sequence
  unmount -at nfs,nfs4
  stop nfsserver
  sync

hangs on the sync.  The 'sync' is trying to write to the NFS filesystem
that has just been unmounted.
I have duplicated the problem on a current mainline kernel.

There are two important facts that lead to the explanation of this.
1/ whenever a 'struct file' is open, an s_active reference is held on
   the superblock, via "open_context" calling nfs_sb_active().
   This doesn't prevent "unmount" from succeeding (i.e. EBUSY isn't
   returned), but does prevent the actual unmount from happening
   (->kill_sb() isn't called).
2/ When a memory mapping of a file is torn down, the file is
   "released", causing the context to be discarded and the sb_active
   reference released, but unlike close(2), file_operations->flush()
   is not called.

Consequently, if you:
 open an NFS file
 mmap some pages PROT_WRITE
 close the file
 modify the pages
 unmap the pages
 unmount the filesystem

the filesystem will remain active, and the pages will remain dirty.
If you then make the nfs server unavailable - e.g. stop it, or tear down
the network connection - and then call 'sync', the sync will hang.

This is surprising, at the least :-)

I have two ideas how it might be fixed.

One is to call nfs_file_flush() from within nfs_file_release().
This is probably simplest (and appears to work).

The other is to add a ".close" to nfs_file_vm_ops.  This could trigger a
(partial) flush whenever a page is unmapped.  As closing an NFS file
always triggers a flush, it seems reasonable that unmapping a page
would trigger a flush of that page.

Thoughts?

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIyBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljAzdcACgkQOeye3VZi
gbmxTA/44OReUFARq/4Tq7dghwBWDrWn2p48SgyWI6B3Kl/0tZupnlD93HM2XuXP
1L2JC/qpQwb1DrSCm0qHjrFRae4JyWOMs3epnlw7vx0myEfZbUWrFDuDki7F0b5w
OgeYkrYsoQAoflHIZO/5CDziAC9olRGZO3LJOtkgSsjUi8UJuXnVWS2H8nlxj+Tu
24ydPEA2WZF6cKmIf+mo364wvbp5Th66i7RbcKBe6AVZnosPzZzBvTonEKxoZmoi
nd/FUF2ThAI/w6TI/mIX9O1/2nXBkcpX7vZaBRazk4JzRCBty1Z7oiPxQUqqsNUv
tImB091efYDjdZt7vQZuz2K267YXiLrZAcAJ+5mEEFn+Pgakt55YpSmFCw2uHVt2
Ml+nGSZ6cE7rxQmBnluO4hBkyLRiLT1PmnW2UvysHLqLk2yNjolkpVOmW4D/+8Ed
Sg/WkwRhQmFEV1kZwAw2wGt9G864JIKwr5va++MEDb6zIMxzcQT/ndc8Mjtkdj3G
vu+57inSLdGEW63vz7gP4R5/dGfumk60yOcOay5Hf5+a3Gfp+Q2ONuOzTHNZjMz0
Hw4PdY7CzRPXgOnevgrEseHF9y0bR80QeCmhvcXStCsrq91w7qJ1fJPdu6NaAxh8
U7c9YA8F3i5GGg0yA8vnwq2B6Id8u+8iSvkB6O6DTEqrAPCMfg==
=bVuU
-----END PGP SIGNATURE-----
--=-=-=--
