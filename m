Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp25.openmailbox.org ([62.4.1.59]:34062 "EHLO
        smtp10.openmailbox.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751077AbcKFCP6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Nov 2016 22:15:58 -0400
To: linux-nfs@vger.kernel.org
From: Luke <g4jc@openmailbox.org>
Subject: File integrity of libtirpc
Message-ID: <6df94115-b0c7-8cc4-efe6-bc671c7e03de@openmailbox.org>
Date: Sat, 5 Nov 2016 22:15:42 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Hello,
I am contacting you as a package maintainer of Parabola GNU/Linux-libre,
a fully free operating system in compliance with the Free Software
Foundation's GNU FSDG. We also have a focus on privacy and security.

We attempt to ensure that all of our packages and upstream are secure.
As such I discovered a problem with your package "libtirpc", and .

There is currently no hash check or GPG signature to verify that the
latest source is actually the one you have created.
This is particularly important since there have been recent attacks
which replaced files on upstream servers. Take for example the Linux
Mint hack earlier this year.
(https://micahflee.com/2016/02/backdoored-linux-mint-and-the-perils-of-c
hecksums/)

I would like to request that you please upload a SHA512 checksum of your
libtirpc tar.gz files, as well as sign the SHA512 with a GPG signature.

Technical documentation on how to do this:
http://docs.oracle.com/cd/E36784_01/html/E36870/sha512sum-1.html
sha512sum * > SHA512SUMS

https://help.ubuntu.com/community/GnuPrivacyGuardHowto
https://access.redhat.com/solutions/1541303
gpg --clearsign -o SHA512SUMS.sign SHA512SUMS


The resulting files, SHA512SUMS and SHA512SUMS.sign, can then be
uploaded to your site (or on another site/server for added security), so
that package maintainers can verify that the source is accurate and
unhacked by a third-party prior to packaging.

Thank you for your time and concern.


Sincerely,
Luke
Parabola GNU/Linux-libre Packager



-----BEGIN PGP SIGNATURE-----

iQIcBAEBCgAGBQJYHpJFAAoJEMP0/88+roaXkqQP/244XuxqF5ujfsA3PR0cq4wq
6+08y4lQY0qm0lk5msy5ipC2RHBq8Su6ojiguJvWy3QEt8F8yqEh9u/BFUubu5fh
JIAMTr5TOzbTtshfs5lxNFLCyhZMBQ8u2OzTkZ5V6Qj07j3IwcXNXQIssw3RdHRq
a7aDOrBzCNlMZbhSbUQvTUJaT0/2HZ1ac9+Z3hczJ4AS1ZWCi2gi4DIqRJtyOwKv
R2mIy8RnETyzRuEKPwuI1BEynVLsGic3Inkn9vNnrSOo5+a7aoe8f66Z/bPXiw+B
11tOQDOZ2vf4Cbz73pkuUW++M/TYacT3X954Yeb994u8FPHY7ud3yvc79hyN0u8Z
M73IlNMJ2LB+RaONGLC9Fbapbzrf4CWmdyVdiNSTu2AxeiPYD6Ke3pEaJgIz2gtJ
6xE3vJW3xDQrbM1aSOoCg/U7+Tw/R5N/NaY22/zO9G5lIkgsV7nsOUqj+1ifEiGK
enZZUB5vadhytQwoQR/jo7qQPM6y1v8HE+VOiAhjVvWV4pnPKrkZ5+Qj55v/XPjJ
108FXQbPLzwOhl1XeJKu+TJ/5IRb2Pt7oYzjkZlqHTlrXuYoyiLNymJfP/tpVnBM
896BFvhuI/dgPkF0rKBZwZ2qM+Rt9vH//hxGRCjoXCYtZD8Rrp1bXilA5EStYnEe
zlsI2KcVZMLI+jkFlXrJ
=ko8t
-----END PGP SIGNATURE-----
