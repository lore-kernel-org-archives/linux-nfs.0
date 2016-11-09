Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38469 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751725AbcKIDqd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Nov 2016 22:46:33 -0500
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>
Date: Wed, 09 Nov 2016 14:46:25 +1100
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Question about nfsdcltrack --storagedir
Message-ID: <87k2cdmi26.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Hi,
 I notice that nfsdcltrack has a "--storagedir" option.
 I wonder how this can be used, given the nfsdcltrack is only(?) called
 from the kernel and there is no(?) mechanism to pass extra options.

 In a clustered-server context it would make sense(?) to share the
 database between cluster nodes and it is easiest to do this if the
 file in a separate filesystem (mounted as part of fail-over) rather
 than in /var.
 This can(?) be achieved using a symlink, but rpm likes to remove
 symlinks to non-existent locations.

 With NFSv3 the equivalent is the state files maintained by statd, and
 these can be relocated by passing the -P option to rpc.statd.
 How does one do a similar thing for NFSv4???

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYIpwRAAoJEDnsnt1WYoG5Q9sQAKyo33XlMueu2RzHp/JLCr+z
4C9SoOvEuyegYijs4ofA8eR7+nhP5/G48B3w6BTmOZyFsrXdP6ZGVp06zvI0RhXW
1u08UxmFodgGyw+vQa8glmWD/b8iF68O0DcfEjDrOBYX9zyg5jS0BZE8PJDQUNAN
KjHMPlXbHtKxG/gZ0bwSh5IEpW8CQjDFYjRkyqoEcQc4d8BGtiViLHCrETzuhVqK
OFFnpn4gpmGYM+Ml0dXbp1A458b6BPZVLId7Rc5LDRccCrY3SSRMC5O04C5pHEVU
UnI5JUaFdIQmOihjz0uKYeuVSCLVbWMmU7coTwnjil55nTKCucvNJZQQcAfO3ll9
KFiAJMja7Cnbz03TdIga8hFsr7zhTWg/OsZPr8Z2AENjSi0ETY78sojy0lJe5Xjm
vrQMPM0qEHld29cnqpWcaFXMTROBGMTtrvAEF94tXNKfKyF8Bg8YOu+nVMCQE8gA
QxP1npx35vca7sjTt7P/vKZBSegzImLBTfN0qj3/DuomLh40GSdTnfxzU9iR2A/I
JueWtupK/0SBGSmr2LA03lA1NrMmDL28GXNKHzqUtRpjxaCW7C9WHysMs0z+0nPb
ydNrEx558tVSnNt8zokWxsGTySd3IhntvxupkQdJ+GW3oRCqUyplXl5JM+MVParx
0rC5avhGEdHdkCVXAwAH
=QI5S
-----END PGP SIGNATURE-----
--=-=-=--
