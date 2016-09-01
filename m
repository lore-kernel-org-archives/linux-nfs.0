Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:40828 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754911AbcIAIJ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Sep 2016 04:09:58 -0400
From: NeilBrown <neilb@suse.com>
To: Karsten Hohmeier <karsten@hohmatik.de>, linux-nfs@vger.kernel.org
Date: Thu, 01 Sep 2016 18:09:50 +1000
Subject: Re: Un-unmountable NFS mountpoints with "Stale NFS file handle" - is this normal behavior?
In-Reply-To: <b0e2b37b-5d90-ea9c-46e9-be577c4da634@hohmatik.de>
References: <b0e2b37b-5d90-ea9c-46e9-be577c4da634@hohmatik.de>
Message-ID: <87a8fsca7l.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Sun, Aug 21 2016, Karsten Hohmeier wrote:

> Dear NFS list members,
>
> I recently contacted a few active NFS devs with an issue i ran into:
>
> We run a XenServer 6.5 (Kernel 3.10) with an older version of nfs-utils
> (1.0.9). NFS mountpoints on that machine acting as a client can not be
> unmounted (not even forcibly or lazy) after the connection to the NFS
> server broke for some reason.
>
> Most commands fail with "Stale NFS file handle".
>
> The Internet tells me this situation is unfixable and requires a reboot
> of the client to resolve. This is a pretty bad solution on a heavily
> loaded virtualization host.
>
> The response of Bruce Fields was: "Sounds like normal behavior, ..."
> (Sorry for not posting to the list in the first place, btw.)
>
> I'm still looking for some explanation why this happens, how it can be
> considered "normal behavior" and if it can be fixed/avoided/mitigated
> without rebooting.

This was fixed 3 years ago in Linux 3.12

Commit: 8033426e6bdb ("vfs: allow umount to handle mountpoints without revalidating them")

(and probably a few other related patches).

You need to be sure you have a version of util-linux where "umount -f"
and "umount -l" don't stat() the mount point.

NeilBrown

>
> Best regards
>
> Karsten Hohmeier
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJXx+JOAAoJEDnsnt1WYoG58DEP/2B9YaT0uVtBE5xwiRj62WpX
pu5gAJw5VokmKh79BipBNicYTIoAkRv0orpBB81zgWrCBOU2c9/pUj5M5XTaDDMj
y39vjjP+W1le5yGGfKpx4dP2fHzgiaWs19q+8znlPHqxmNVeCX4O2s3vTsyTSRnD
b8bUUBaLVCfxtwZVl7gstRZUr1mrsfTHyZXTicq9Z3OHosOcH1bJglZ/AcLDj3fL
5Zd7h6sFVrT8R8ZXvuuFCn20+YIyY4icLG5okGO/SzzWO+7gI1MLlcZeKkRVhqIL
L8MX6xPndcpYvp+0FQR4mD7viYni7jUKBpV+2ffhlHA+l/d/Xsg5oAkb+jhyBLF0
LbCjID8HmQOjvvzybQkatcCP2tkB6BzpBKE7OFWIPGc8mr6DTIxQB3Gs+3s43yfg
Icj+0MV5Oa/Lz47Kqd8txv16aHYColZ3sh7pM9Hx5dGD8iAiIxrAojssOMpZM5Ml
PNAbrHOAiAqhAYpu2zmc6MBDPwmHrO9GGUNhkHN1PbNHxkEbP3+JsqPhKetqjxhI
8MGLGGSaY5hW15lKiebvuX8NvaHPjfrjNUX7h2RYQYPPDqEdlMmhK/5uodh9TTro
VtiId0BPZGxtbG0vB+zjG6q5Ej2jysNwQQ7eFVtxUpGosWhNI6H1qEQB4sokBHf5
AIGPECjdtBzvTaX+ClP+
=VAZC
-----END PGP SIGNATURE-----
--=-=-=--
