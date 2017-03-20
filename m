Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.total-security.at ([86.59.114.232]:42113 "EHLO
        mail.total-security.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753437AbdCTMdL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Mar 2017 08:33:11 -0400
To: <linux-nfs@vger.kernel.org>
From: Leonhard Preis <leonhard.preis@radarservices.com>
Subject: mountd v4root ignores anonuid and anongid for pseudo file system
Message-ID: <4218b9fa-e215-370a-f913-348e055d33e2@radarservices.com>
Date: Mon, 20 Mar 2017 13:17:40 +0100
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature";
        boundary="KX2rbMQK9s75qv7B4MjLI8r06BSB9XT1o"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--KX2rbMQK9s75qv7B4MjLI8r06BSB9XT1o
Content-Type: multipart/mixed; boundary="3NNnAlVhNHQXKNl3QeHujIFMWOWRQvHkj";
 protected-headers="v1"
From: Leonhard Preis <leonhard.preis@radarservices.com>
To: linux-nfs@vger.kernel.org
Message-ID: <4218b9fa-e215-370a-f913-348e055d33e2@radarservices.com>
Subject: mountd v4root ignores anonuid and anongid for pseudo file system

--3NNnAlVhNHQXKNl3QeHujIFMWOWRQvHkj
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi!

Recently I have been investigating[1] why Vagrant=E2=80=99s automatically=

created NFS shares fail to mount when using NFSv4 on Ubuntu 16.04 while
they work fine on Debian Stretch. In the end the cause really is
trivial: Debian created my home directory with 0755 while Ubuntu went
with 0700. The pseudo file system created by mountd seems to mirror
these permissions while ignoring that Vagrant set
`all_squash,anonuid=3D1000,anongid=3D1000`. Thus the client trying to mou=
nt
the exported directory is denied access. In my opinion this is a bug
since uid and gid 1000 would have access to the home directory. But I do
see that a second NFS share without the exact same options would create
a dilemma. At the very least a log message indicating this situation
would be very helpful. Nevertheless I=E2=80=99m not too familiar with NFS=
 and
would appreciate your take on this.

While the solution is simple my lack of knowledge had me dive deep into
the web to understand what was going wrong. My biggest obstacle was
definitely the documentation. While the automatically created pseudo
file system was introduced back in 2010[8][9] it is hardly documented[5]
=2E The closest one can get to understand to what=E2=80=99s happening wit=
hout
diving into the source code and the accompanying git log itself is a
very outdated discussion from before it was implemented and a note
saying that =E2=80=9Call of this has since been mostly fixed=E2=80=9D[6].=
 Meanwhile
almost every tutorial on NFSv4 I remember reading last week still claims
you need to set up a pseudo root. While some may not claim it there is
not a single one explaining what is happening if you don=E2=80=99t includ=
ing the
man page[3][4][12]:

> For NFSv4, there is a distinguished filesystem which is the root of
all exported filesystem.  This is specified with fsid=3Droot or fsid=3D0
both of which mean exactly the same thing.

Especially confusing is the following statement from mountd=E2=80=99s man=
 page[4]:

> The rpc.mountd daemon implements the server side of the NFS MOUNT
protocol, an NFS side protocol used by NFS version 2 [RFC1094] and NFS
version 3 [RFC1813].

For me this sounds almost like NFSv4 does not use mountd. Apparently
even Novell thinks that[11]:

> rpc.mountd =E2=80=94 [=E2=80=A6] This is not used with NFSv4.

Last but not least it=E2=80=99s not exactly helping that mountd does not =
log its
debug stuff to journald, only daemon.log (Debian) or syslog (Ubuntu). I
admit to failing to find these logs until the end when I grep=E2=80=99d f=
or
=E2=80=9Cv4root=E2=80=9D in the log directories. But I have seen that the=
re=E2=80=99s something
happening in regards to systemd with version 2 of nfs-utils so that
point may be moot.

Oh, and one more thing: mountd hiding the pseudo exports to showmount[2]
and exportfs without an option to show them anyway is yet another hint
denied. My personal highlight is the, usually top-notch, Arch Wiki[7]
which has a (disputed) claim[7] that NFS requires shares to reside below
/srv. I hope to find some time this week to improve their documentation.

While I may have had a lot of fun with the documentation, I have no
complaints about the rock-solid software itself and want to use this
opportunity to thank the developers for all their efforts!

As I wrote before I kindly ask for your opinion on the matter and what I
may have missed. Thank you!

Cheers,

Leonhard

[1] https://github.com/mitchellh/vagrant/issues/8279

[2]
http://git.linux-nfs.org/?p=3Dsteved/nfs-utils.git;a=3Dpatch;h=3Dde108c53=
1e29ba936a68a6efb99095ad6d6cec8f

[3]
http://git.linux-nfs.org/?p=3Dsteved/nfs-utils.git;a=3Dblob;f=3Dutils/exp=
ortfs/exports.man;h=3Dd8de6bec2583144bace5a7352d5db58e0882e60d;hb=3DHEAD


[4]
http://git.linux-nfs.org/?p=3Dsteved/nfs-utils.git;a=3Dblob;f=3Dutils/mou=
ntd/mountd.man;h=3D9978afcdb4ccb3ef59e5007fa93a1519062cb45c;hb=3DHEAD

[5] http://wiki.linux-nfs.org/wiki/index.php/Nfsv4_configuration

[6] http://wiki.linux-nfs.org/wiki/index.php/Pseudofilesystem_improvement=
s

[7]
https://wiki.archlinux.org/index.php/NFS/Troubleshooting#mount.nfs4:_acce=
ss_denied_by_server_while_mounting

[8]
http://git.linux-nfs.org/?p=3Dsteved/nfs-utils.git;a=3Dpatch;h=3Db2569432=
0f2bdd79de82f2003209b8229eafff36

[9]
http://git.linux-nfs.org/?p=3Dsteved/nfs-utils.git;a=3Dpatch;h=3D3b777b08=
4a438f55482c8bf7508903ff4c30e1db

[10]
http://git.linux-nfs.org/?p=3Dsteved/nfs-utils.git;a=3Dpatch;h=3Dde108c53=
1e29ba936a68a6efb99095ad6d6cec8f

[11] https://www.novell.com/coolsolutions/feature/17581.html

[12]
http://git.linux-nfs.org/?p=3Dsteved/nfs-utils.git;a=3Dblob;f=3Dutils/exp=
ortfs/exportfs.man;h=3D91d3589e38d62cb72a343b13b10f0052aec1cbfd;hb=3DHEAD=




--3NNnAlVhNHQXKNl3QeHujIFMWOWRQvHkj--

--KX2rbMQK9s75qv7B4MjLI8r06BSB9XT1o
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEfyT2e8BIJorFzScvxAt5r6FJNI8FAljPyHQACgkQxAt5r6FJ
NI+KlQ//Tsc4zV43ik6xm/69Uzc1cMEUtlTev/hSnNhbtHEpLdSHphGLhEbaEIkk
FqhowXbFcDlhoogdDjUBNX39yEqV+AQH+8JO1LlPryG9dEPrFVrczgjMRq7sLCpC
FxUM4sGhVflqqsQe1oMOOqcW9u+w2efxbE/DSFAbiDSaLv1wdiaWlmv2nXexlgZB
MGjla5vMe2+x7UprBU84s+pwatGlJQ4c1tNBEVSkeZ1Cp+V/P1ZR+wNQPkKT0OoT
MBGxh5uHWCmQJL7yqUvmifdyZxlutoXS8y+J0K+JcP5tWne3xmjxclC7IjVOLQeP
ntKiMKqKvzAUh7RsF7AzNmYboOwEo9mQW2QkqbDH1YK3+TNXWcqaAKNf5K1Qta8n
ImDT2gFZ2oRjJoWFzrp8cWzuwNlTaBUNzFLyq7mBjDp9Bp3BbEpoaap0e8SUJfUm
bRQrUyExlKQ5BfEKA2XBBeq+9nhBAFxqftv8vjTJXkxZEeuk6RjEFyBZRBxcdsT/
D48ATJQRv1/qbOz8mkdvwffb+EuaKIJyCIbE+hwuIat+F2w6vRLdP832JdUGS/xA
10r9dMSVx7YgYB1cpJ3jr3Fnw0Ix6FuEAI5oGYoI9bvwyl5XzE1OlYP2E44mFQk7
Tq3LgULnHvZAJpoao3qlSc/GG5g50dh485VFuNnMUnMdcEr/wbk=
=RB4Y
-----END PGP SIGNATURE-----

--KX2rbMQK9s75qv7B4MjLI8r06BSB9XT1o--
