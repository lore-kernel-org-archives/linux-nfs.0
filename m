From: Nico -telmich- Schottelius <nico-linux-next@schottelius.org>
Subject: Updated Next/Trees, problems with nfs-git
Date: Mon, 4 Aug 2008 15:44:44 +0200
Message-ID: <20080804134444.GC4182@denkbrett.schottelius.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pQhZXvAqiZgbeUkD"
Cc: linux-nfs@vger.kernel.org
To: linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--pQhZXvAqiZgbeUkD
Content-Type: multipart/mixed; boundary="qtZFehHsKgwS5rPz"
Content-Disposition: inline


--qtZFehHsKgwS5rPz
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello!

I just tried to fetch all trees listed in Next/Trees.
Therefore I updated Trees to have arm via http instead of master ssh
(so non-kernel-devs can fetch it) and updated a typo for lsm and agp.

The scripts I use can be found in my ~/bin-git:

http://unix.schottelius.org/cgi-bin/gitweb.cgi?p=3Dnsbin;a=3Dcommit;h=3D41a=
bb532b828c1c704d10566918c2d42637d161d

The patch for Trees in attached (Signed-off-by: Nico Schottelius <nico@denk=
brett.schottelius.org>).

The nfs-tree failed:

[15:37] denkbrett:linux-nico% sh ~/bin/linux/merge-branches.sh
fatal: Couldn't find remote ref refs/heads/linux-next
Problem with nfs (see above)


Sincerly,

Nico

--=20
Think about Free and Open Source Software (FOSS).
http://nico.schottelius.org/documentations/foss/the-term-foss/

PGP: BFE4 C736 ABE5 406F 8F42  F7CF B8BE F92A 9885 188C

--qtZFehHsKgwS5rPz
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="Trees.diff"

--- Trees.orig	2008-08-04 15:16:12.152650055 +0200
+++ Trees	2008-08-04 15:39:45.543588078 +0200
@@ -8,7 +8,7 @@
 net-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git#master
 sparc-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6.git#master
 sound-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6.git#for-linus
-arm-current	git	ssh://master.kernel.org/home/rmk/linux-2.6-arm.git#master
+arm-current	git	http://ftp.arm.linux.org.uk/pub/linux/arm/kernel/git-cur/linux-2.6-arm.git/#master
 pci-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6#for-linus
 wireless-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git#master
 kbuild-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixes.git#master
@@ -70,7 +70,7 @@
 crypto		git	git://git.kernel.org/pub/scm/linux/kernel/git/herbert/cryptodev-2.6#master
 vfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git#for-next
 sound		git	git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6.git#for-next
-arm		git	ssh://master.kernel.org/home/rmk/linux-2.6-arm.git#devel
+arm		git	http://ftp.arm.linux.org.uk/pub/linux/arm/kernel/git-cur/linux-2.6-arm.git/#devel
 cpufreq		git	git://git.kernel.org/pub/scm/linux/kernel/git/davej/cpufreq.git#next
 v9fs		git	git://git.kernel.org/pub/scm/linux/kernel/git/ericvh/v9fs.git#for-next
 rr		quilt	http://ozlabs.org/~rusty/kernel/rr-latest/
@@ -83,7 +83,7 @@
 bkl-removal	git	git://git.lwn.net/linux-2.6.git#bkl-removal
 trivial		git	git://git.kernel.org/pub/scm/linux/kernel/git/juhl/trivial-2.6.git#next
 ubifs		git	git://git.infradead.org/~dedekind/ubifs-2.6.git#linux-next
-lsm		git	git://gitkernel.org/pub/scm/linux/kernel/git/chrisw/lsm-2.6.git#for-next
+lsm		git	git://git.kernel.org/pub/scm/linux/kernel/git/chrisw/lsm-2.6.git#for-next
 block		git	git://git.kernel.dk/linux-2.6-block.git#for-next
 embedded	git	git://git.infradead.org/embedded-2.6.git#master
 firmware	git	git://git.infradead.org/users/dwmw2/firmware-2.6.git#master
@@ -107,4 +107,4 @@
 security-testing	git	git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6.git#next
 lblnet		git	git://git.infradead.org/users/pcmoore/lblnet-2.6_next#master
 ttydev		quilt	http://www.linux.org.uk/~alan/ttydev/
-agp		git	git://git.kernel.org//pub/scm/linux/kernel/git/airlied/agp-2.6.git#agp-next
+agp		git	git://git.kernel.org/pub/scm/linux/kernel/git/airlied/agp-2.6.git#agp-next

--qtZFehHsKgwS5rPz--

--pQhZXvAqiZgbeUkD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiXB8wACgkQuL75KpiFGIyTnACg3MgTuDUAP1XekZdc/sOyzXXZ
V30AnjaWNtRmD7JsUcqoyB05lu5aQ6VB
=3F9g
-----END PGP SIGNATURE-----

--pQhZXvAqiZgbeUkD--
