From: Nico -telmich- Schottelius <nico-linux-next@schottelius.org>
Subject: Re: Updated Next/Trees, problems with nfs-git
Date: Mon, 4 Aug 2008 17:09:40 +0200
Message-ID: <20080804150940.GF4182@denkbrett.schottelius.org>
References: <20080804134444.GC4182@denkbrett.schottelius.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="e5bfZ/T2xnjpUIbw"
Cc: linux-nfs@vger.kernel.org
To: linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080804134444.GC4182@denkbrett.schottelius.org>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--e5bfZ/T2xnjpUIbw
Content-Type: multipart/mixed; boundary="8bBEDOJVaa9YlTAt"
Content-Disposition: inline


--8bBEDOJVaa9YlTAt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello again!

Found out that #linux-next should have been #nfsd-next and updated
the patch to match.

Patch attached.

Nico

--8bBEDOJVaa9YlTAt
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="Trees.diff"

Update Next/Trees

Signed-off-by: Nico Schottelius <nico@denkbrett.schottelius.org>

diff --git a/Next/Trees b/Next/Trees
index bae9377..94a3962 100644
--- a/Next/Trees
+++ b/Next/Trees
@@ -8,7 +8,7 @@ scsi-rc-fixes	git	git://git.kernel.org/pub/scm/linux/kernel/git/jejb/scsi-rc-fix
 net-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6.git#master
 sparc-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/davem/sparc-2.6.git#master
 sound-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6.git#for-linus
-arm-current	git	ssh://master.kernel.org/home/rmk/linux-2.6-arm.git#master
+arm-current	git	http://ftp.arm.linux.org.uk/pub/linux/arm/kernel/git-cur/linux-2.6-arm.git/#master
 pci-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/jbarnes/pci-2.6#for-linus
 wireless-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git#master
 kbuild-current	git	git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-fixes.git#master
@@ -41,7 +41,7 @@ jfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/shaggy/jfs-2.6.git#next
 kbuild		git	git://git.kernel.org/pub/scm/linux/kernel/git/sam/kbuild-next.git#master
 ide		quilt	http://kernel.org/pub/linux/kernel/people/bart/pata-2.6/patches/
 libata		git	git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/libata-dev.git#NEXT
-nfs		git	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#linux-next
+nfs		git	git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git#nfsd-next
 xfs		git	git://oss.sgi.com:8090/xfs/xfs-2.6.git#master
 infiniband	git	git://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git#for-next
 acpi		git	git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-acpi-2.6.git#test
@@ -70,7 +70,7 @@ wireless	git	git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-nex
 crypto		git	git://git.kernel.org/pub/scm/linux/kernel/git/herbert/cryptodev-2.6#master
 vfs		git	git://git.kernel.org/pub/scm/linux/kernel/git/viro/vfs-2.6.git#for-next
 sound		git	git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound-2.6.git#for-next
-arm		git	ssh://master.kernel.org/home/rmk/linux-2.6-arm.git#devel
+arm		git	http://ftp.arm.linux.org.uk/pub/linux/arm/kernel/git-cur/linux-2.6-arm.git/#devel
 cpufreq		git	git://git.kernel.org/pub/scm/linux/kernel/git/davej/cpufreq.git#next
 v9fs		git	git://git.kernel.org/pub/scm/linux/kernel/git/ericvh/v9fs.git#for-next
 rr		quilt	http://ozlabs.org/~rusty/kernel/rr-latest/
@@ -83,7 +83,7 @@ semaphore-removal	git	git://git.kernel.org/pub/scm/linux/kernel/git/willy/misc.g
 bkl-removal	git	git://git.lwn.net/linux-2.6.git#bkl-removal
 trivial		git	git://git.kernel.org/pub/scm/linux/kernel/git/juhl/trivial-2.6.git#next
 ubifs		git	git://git.infradead.org/~dedekind/ubifs-2.6.git#linux-next
-lsm		git	git://gitkernel.org/pub/scm/linux/kernel/git/chrisw/lsm-2.6.git#for-next
+lsm		git	git://git.kernel.org/pub/scm/linux/kernel/git/chrisw/lsm-2.6.git#for-next
 block		git	git://git.kernel.dk/linux-2.6-block.git#for-next
 embedded	git	git://git.infradead.org/embedded-2.6.git#master
 firmware	git	git://git.infradead.org/users/dwmw2/firmware-2.6.git#master
@@ -107,4 +107,4 @@ voltage		git	git://git.kernel.org/pub/scm/linux/kernel/git/lrg/voltage-2.6.git#r
 security-testing	git	git://git.kernel.org/pub/scm/linux/kernel/git/jmorris/security-testing-2.6.git#next
 lblnet		git	git://git.infradead.org/users/pcmoore/lblnet-2.6_next#master
 ttydev		quilt	http://www.linux.org.uk/~alan/ttydev/
-agp		git	git://git.kernel.org//pub/scm/linux/kernel/git/airlied/agp-2.6.git#agp-next
+agp		git	git://git.kernel.org/pub/scm/linux/kernel/git/airlied/agp-2.6.git#agp-next

--8bBEDOJVaa9YlTAt--

--e5bfZ/T2xnjpUIbw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkiXG7QACgkQuL75KpiFGIz5dgCfdB1FONsmkmKBBXeb8+p/hUu0
MgwAn0YC7Lgr8NmCsmD91F8oTveMLxjK
=oKpO
-----END PGP SIGNATURE-----

--e5bfZ/T2xnjpUIbw--
