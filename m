Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40679 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750710AbcKEWD4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 5 Nov 2016 18:03:56 -0400
From: NeilBrown <neilb@suse.com>
To: Luis de Bethencourt <luisbg@osg.samsung.com>,
        linux-fsdevel@vger.kernel.org
Date: Sun, 06 Nov 2016 09:03:45 +1100
Cc: Richard Weinberger <richard@nod.at>, linux-nfs@vger.kernel.org
Subject: Re: When is export_operations.get_parent triggered?
In-Reply-To: <581DD7B0.8080906@osg.samsung.com>
References: <581DD7B0.8080906@osg.samsung.com>
Message-ID: <8760o1pose.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Sat, Nov 05 2016, Luis de Bethencourt wrote:

> Hi all,
>
> I recently played with adding the basics to make befs exportable via NFS [0].
>
> I want to implement the get_parent member of the export_operations struct as
> well, but I can't seem to trigger this member being called. I have implemented
> a solution which I feel is wrong [1], but want to be able to test it before
> moving forward.
>
> When is this member triggered? Any advice?

This is required when a filehandle for a directory arrives, but the
directory is not in the dcache.
NFSD needs to find dentries for the directory, the parent, the
grandparent etc all the way up to the root.

The simplest way to trigger this is to mount the filesystem onto a
different machine, 'cd' into a fairly deep directory, then reboot the
server (or unexport, unmount, remount, re-export).
Now 'ls -l' on the client.  That should trigger calls to ->get_parent.

->get_parent() is a log like performing a lookup of "..".

NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYHldBAAoJEDnsnt1WYoG5mwEP+wSVR2wwD9lTyz3K5sflnpgP
USHVQrhxBtKTLAWm4g9g37bouK6PSZmImBw9ZGpgpU+YqHdeV2GsS4TfFeOGEhKj
DAkXuOSx2dkru4r4xNVLvO4Y10zbLN17J0iL8+/wJMEO8OAaeClqfyLk14x+Fb8k
1uMl3reC+mxBMVrc9F135qiPoVrO0DF4dIn5kIsVLpC+7eVGvAmjrn/lcqhyhneK
zmZz9tfcVVH8j0BWDsUAhWJOqrH6whkDEXHe8Cg1pqseCCOxCZwl83QhqmH3tayp
8+44PT9KIm9751aZY9ovHqLofB4tgVyKTLBTAEpA/3f+SPo9d26DJ+f7Lw512WpV
1Hw7VtLkhI5IxXEVb9SgdDpC8OqPu4mkVCMsdpYM5+kq8qUKon4JPgX6L0GYCq4U
nr96cHqsl6G2myOD06Sk1ImqHBdTpoo4ah8pPIjuSEqTErLxEsIDIwr/zOTYLIYH
wG8+4rxwtqzid2rnxLy8dcDEXQVlb7OkXtm7ih8/KMo54xdiBp9jjjn231OnF7WL
CJ32BH5GKOqa6ihu7t1LVPssOfu2QzXRJXm2QgQhqy3DyaiV9Kv9dCAR0zsI1FRz
y4C3PjgA39qYaEdKnQVLHiCVzCTQzC/rAR96i4y+2lpDb8OF+YEfg/LbhTKYwfwi
cU8hDYTYGfCC7Lh8Zv0/
=Spjb
-----END PGP SIGNATURE-----
--=-=-=--
