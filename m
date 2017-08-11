Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44350 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751299AbdHKEbW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Aug 2017 00:31:22 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Date: Fri, 11 Aug 2017 14:31:10 +1000
Subject: Do we really need d_weak_revalidate???
cc: Michal Koutny <mkoutny@suse.com>
cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Message-ID: <87bmnmrai9.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


Funny story.  4.5 years ago we discarded the FS_REVAL_DOT superblock
flag and introduced the d_weak_revalidate dentry operation instead.
We duly removed the flag from NFS superblocks and NFSv4 superblocks,
and added the new dentry operation to NFS dentries .... but not to NFSv4
dentries.

And nobody noticed.

Until today.

A customer reports a situation where mount(....,MS_REMOUNT,..) on an NFS
filesystem hangs because the network has been deconfigured.  This makes
perfect sense and I suggested a code change to fix the problem.
However when a colleague was trying to reproduce the problem to validate
the fix, he couldn't.  Then nor could I.

The problem is trivially reproducible with NFSv3, and not at all with
NFSv4.  The reason is the missing d_weak_revalidate.

We could simply add d_weak_revalidate for NFSv4, but given that it
has been missing for 4.5 years, and the only time anyone noticed was
when the ommission resulted in a better user experience, I do wonder if
we need to.  Can we just discard d_weak_revalidate?  What purpose does
it serve?  I couldn't find one.

Thanks,
NeilBrown

For reference, see
Commit: ecf3d1f1aa74 ("vfs: kill FS_REVAL_DOT by adding a d_weak_revalidate dentry op")



To reproduce the problem at home, on a system that uses systemd:
1/ place (or find) a filesystem image in a file on an NFS filesystem.
2/ mount the nfs filesystem with "noac" - choose v3 or v4
3/ loop-mount the filesystem image read-only somewhere
4/ reboot

If you choose v4, the reboot will succeed, possibly after a 90second timeout.
If you choose v3, the reboot will hang indefinitely in systemd-shutdown while
remounting the nfs filesystem read-only.

If you don't use "noac" it can still hang, but only if something slows
down the reboot enough that attributes have timed out by the time that
systemd-shutdown runs.  This happens for our customer.

If the loop-mounted filesystem is not read-only, you get other problems.

We really want systemd to figure out that the loop-mount needs to be
unmounted first.  I have ideas concerning that, but it is messy.  But
that isn't the only bug here.

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmNMxEACgkQOeye3VZi
gbngcBAAr/WifI4hL0Bb9c/EJo6CnaOKRxiJxdafUGpNnCCtcIO7E0suDM8nh8kx
KktEcDzjou70k/d0/YVWpHKNbRLBvpRrTRb+Gb/+parrAXZwsLeKUNQX88YEJuSG
AeWfy7HdX3sPgpZWjE5JkcrHWj4eBBhQGce1gdZuv3kY8evqC3ZrNoUk7fk4bRzR
eh0D7034LAeZJLLeTmHxR1kM1D8Iv1CKLZr0hQZKl8JZu+FeY7pZeeX7j2WD3jFw
t9TgMTf1k66ftytSv9xO8wdKaQGwjcw/RVSz7jHDNxSY3rXv6G5WFrL81KuHmcE4
KYXF4sGoYaUwJm4p9P9XYgkxSicxtx2w2xXR6ugLpUHgxzVX1zk861TLLSNsdggx
b6tEgEjZaGWa4WiEW+3x6uKapey2WBOZYWpVed7vNl7WgFDLwEPq6xcVzr41kddg
kM4rEm467ibWqMAeMLVmaMLuoTuKG0PVab6jHpxdVVRWpgCVsq6AHcNT1Zb9AFZP
BsKlbGDb6Lmuj3jPArXCkkRKxb62N3U01bosS5KR2zexJwqWZdfWYa2Fs6LbRuUg
o6Vpr4WjX5kL7HAtbny6QLRntvtBQp1gr5Pz2rBexE/jdvrMIxCP/B0wofvPKC+y
SXVDmy3jk0Wr09yl2o2QayhvymNJalK/wJbtZLrSC0499YGv5Ls=
=zajR
-----END PGP SIGNATURE-----
--=-=-=--
