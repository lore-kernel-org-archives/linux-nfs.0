Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:39068 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751882AbcJMHdm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Oct 2016 03:33:42 -0400
Received: from relay2.suse.de (charybdis-ext.suse.de [195.135.220.254])
        by mx2.suse.de (Postfix) with ESMTP id 916D1AC47
        for <linux-nfs@vger.kernel.org>; Thu, 13 Oct 2016 07:18:09 +0000 (UTC)
From: NeilBrown <neilb@suse.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Thu, 13 Oct 2016 18:18:04 +1100
Subject: Incorrect(?) use of open_state->stateid in pnfs
Message-ID: <87zim8zphv.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Suppose I open/create a file over pNFS and am given a WRITE delegation.
I then chmod the file (as rsync is wont to do) so the delegation is
immediately returned.
I then proceed to write, which triggers a LAYOUT_GET request.  The
stateid for that request it taken from state->stateid, which is still
the delegation stateid.  Naturally it gets NFS4ERR_BAD_STATEID.

When an OPEN is given a delegation, the delegation stateid gets copied
into ->stateid and the open stateid is left in ->open_stateid.
When the delegation is returned, this it done by inode, not open_state,
so it doesn't have easy access to reset the ->stateid.   It could find
all the open_states and fix them up I guess it ....

Other than this usage in pnfs (which dates back to commit b1f69b754e and
is, I believe, incorrect) the ->stateid is *only* used to help find the
write state to recover when an error is reported and the state needs to
be recovered (... though the usage in nfs4_do_handle_exception()
introduced by 272289a3df is a bit different).

Anyway, no other code uses it when choosing a stateid to send in a
request.  So no other code inadvertently uses the delegation stateid
after it has been returned.

How should this be fixed?

- have nfs_start_delegation_return() iterated over all open states
  and copy the open_stateid over the stateid??

- have pnfs_update_layout() use ->open_stateid rather than ->stateid ??
  I suspect that would be wrong.

- have pnfs_update_layout() use ->open_stateid if NFS_I()->delegation
  is NULL ??

Something else?

The last seems easiest, but I'm not certain it is best.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJX/zUsAAoJEDnsnt1WYoG5vd4QAL/hD0l0IZe7w3qdGen+ocdZ
0hLyL3rAJCfLlfeiz0jYxkgBm3SAwi5VX44hVuHZs+gbPXQGF0vcGjJr0vtDEuu8
2rmiFZY9eweM+pXFFeunICajs0FpEWc7oZombLNhpVtmZVMJgcRbGB713QRTVj75
hOtroc57paHQRcDd7zTRR4YDE9l3hLLsDapDcy7jxzZPDo12ia/d30vPFlOZ4/jU
z3pyGUMS+WO/Qjba6dcBBCv+fX45B8MaZWcVfEUXrCt5yR7RncxoC8zShfjaLON+
WmDnZxS+B9hK/v4oCFvUZQfWKyS+QtyBEQzUX8slBaYe37I+AKZ/ZDW6eSSioQn5
GAyklW1/KvCLQ5WIq0YE+aSHqBVlONqmZ4QaUTVAi/7oNOESQ8p2F3QL+5CDh8mg
i99RZGY1uDPcZ4YilFygp8SbBKTZjEnyN+cGuquyn8/TRDW9UjXDZVS/BsQO2TWL
UCDprkSQpkNaklqtpRAWL6XX60rr3GXtTpmDZFBQ4JWC78/UG3pD/8oyl+Yj3Twj
I57jMjDaMFFMlunkeNpGGtGwRy+z0ktx5DIu3YZic9pGo8hruyvzWiqx4VXws25h
GDdcN0xvi+Ihch1FKhWIGxpNESmqGMHuqyAdcR1DjGoJHeEd5hyXw8UyfqMnh/hg
db3IDUZ3uEmW9gvBb7DM
=kQsD
-----END PGP SIGNATURE-----
--=-=-=--
