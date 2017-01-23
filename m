Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33591 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750707AbdAWAOB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jan 2017 19:14:01 -0500
From: NeilBrown <neilb@suse.com>
To: systemd-devel@freedesktop.org,
        List Linux NFS Mailing <linux-nfs@vger.kernel.org>
Date: Mon, 23 Jan 2017 11:13:52 +1100
Subject: RequiresMountsFor and the noauto option.
Message-ID: <87inp6eipr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain


hi,
 according to "man systemd.unit" :

       RequiresMountsFor=
           Takes a space-separated list of absolute paths.
           Automatically adds dependencies of type Requires= and
           After= for all mount units required to access the
           specified path.

           Mount points marked with noauto are not mounted
           automatically and will be ignored for the purposes of
           this option. If such a mount should be a requirement for
           this unit, direct dependencies on the mount units may be
           added (Requires= and After= or some other combination).


 I understand this to mean that if a mount point has the "noauto" option in
 /etc/fstab, and if a systemd service has RequiresMountsFor the path to
 that mount point, then the service will *not* require the mount point,
 and it will start even if that mountpoint cannot be mounted.

 I recently made a change to nfs-utils to make use of this
 functionality.  A generator creates RequiresMountsFor dependences for
 nfs-server so that it won't start until all exported filesystems
 (listed in /etc/exports) are mounted.  I assumed this would not trigger
 the mounting of filesystems marked as "noauto".  I really want After
 functionality, but not Requires.

 However, this is not how it works.

 The "noauto" option stops a "Requires" dependency being created for
 local-fs.target, but does not stop a "Requires" dependency being
 created for a service which "RequiresMountsFor".  There is no checking
 for "noauto" in unit_add_mount_dependencies().

 If this a bug in the documentation, or a bug in the code?  I'm hoping
 the later, otherwise I'll need to find a different solution for
 nfs-utils, and that will probably require having my generator read
 /etc/fstab and duplicate the work of fstab-generator.c

 If the documentation is wrong, and the code is correct, would it be
 possible to get "AfterMountsFor=" as that is the functionality that I
 really want.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAliFSsAACgkQOeye3VZi
gbkpBQ//Qiu0i0DINjH0XorUCcrwrnnKGyFpfwDbkAFSCHDseIZo9hLg/UhvRiLk
HOjAYYThNDiICcmtQLLQAF7MvuU420BcjAoOQ5vU5l2YmxLH9vyDtgq4YdtKcF9z
zjuqvOplAMtIeE0GlOXnsHYd0U71jcUlMmpudlwwsFmJTXGbpKYBtRy2KVnViMPu
Dn47mWjxO1j9zGi+lLAuJj2izHCbLei82xMgw+EHXaqRgtIKBqaKDpGXMhkHsKK8
0bx/FDaQrgOOPFC+37DBRQEQksL9PoK/g9uhroKuX+IzbsznXsts2DAm4pR2EMF4
VH17ropcGLm944eLcihC+FLyu80gj7pX4CV6AmPBtVNsuer1deOoSu+yAizkAsWO
IGjRp5IYft0kr8z8webMxcW7/9c6nAXAa+M3oaj1FkKHRiW7ZCpHj7iBNlnNKrbW
4BbeOensY0ndR83mFQoiKQAB42VgLRqCqdPl1Blbyvw7DkUw9T1CmZzfVEEg+k78
Hx+B+vaL6K3aJRfiCiyD4QgLKwV8Oj9a4N/vrEMIE5z4GGUrf3WgoHROZtynUAUf
X74AhW5AMwxEn6m6ViIl40OOhKQGxgOjcafGG6wfJ5uXjiH/hvw1m2u6rupepG93
EaHg7vzdWlP2R6JD8ETltfkJ4aoIVBLsGV8lIUKuknxK8Xp0daU=
=4wiS
-----END PGP SIGNATURE-----
--=-=-=--
