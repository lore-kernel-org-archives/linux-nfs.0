Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate-02.zdv.uni-mainz.de ([134.93.178.246]:15773 "EHLO
	mailgate-02.zdv.uni-mainz.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752563AbbFQM7v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2015 08:59:51 -0400
Message-ID: <55816C84.1080608@uni-mainz.de>
Date: Wed, 17 Jun 2015 14:48:04 +0200
From: Christoph Martin <martin@uni-mainz.de>
MIME-Version: 1.0
To: Andy Adamson <andros@netapp.com>, "J. Bruce Fields" <bfields@fieldses.org>
CC: Markus Tacke <tacke@uni-mainz.de>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] make nfsd_drc_max_mem configurable
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature";
	boundary="O9EFGWeqDssTiUSJwphFkQNfT1NRbuIQu"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--O9EFGWeqDssTiUSJwphFkQNfT1NRbuIQu
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Dear Andy, dear Bruce,

(sorry for the recent to you, I now cc'd linux-nfs)

I have attached a patch to nfssvc.diff to make the size of the drc nfsd
cache configurable.

In the last month we were stumbling twice over the problem that the
NFS4.1 session cache was to small.

The first time we wanted to setup a NFS Server for our HPC cluster. We
were wondering why we were only able to mount the filesystem on 380 of
our ~700 nodes. It took us a long time to find out that it was the limit
of the NFS4.1 session cache. Since this machine had 12G Ram, the kernel
reserved 12M for the cache, which results in 384 slots a 32k:

echo $(((12582912>>10)/32))
384

We patched the kernel redhat 7 kernel to change NFSD_DRC_SIZE_SHIFT to
from 10 to 7 to fix this problem.

The second time we installed a small Debian VM with 1G ram to act as a
NFS4 referral server for the home and group directories on our campus.
Since the server does only NFS referrals it does not really need more
memory than the 1G. But it could only server about 30 clients with this
limitation of the session cache.

I think it would be a good idea to have the amount of memory
configurable in nfsd. So I wrote this small patch to make drc_size
configurable while loading the kernel nfsd module.

The patch uses the old value computed from NFSD_DRC_SIZE_SHIFT as the
lower limit. If drc_size as a parameter for then nfsd is higher than a
1/1000 of the RAM, this value will be used.

One might consider to make NFSD_DRC_SIZE_SHIFT even higher to use less
memory for situations where it is not needed. I did not implement an
upper limit, but it might be important.

Please consider to include this patch into the nfsd code.

Yours
Christoph Martin

--- linux-source-3.16/fs/nfsd/nfssvc.c	2015-03-30 12:09:09.000000000 +020=
0
+++ linux-source-3.16.nfsd/fs/nfsd/nfssvc.c	2015-06-17
09:28:37.880443867 +0200
@@ -359,11 +359,19 @@ void nfsd_reset_versions(void)
  * For now this is a #defined shift which could be under admin control
  * in the future.
  */
+
+static ulong drc_size =3D 0;
+module_param(drc_size, ulong, 0444);
+MODULE_PARM_DESC(drc_size,
+		 "size of NFSv4.1 DRC cache memory (default and minimum:
free_buffer_size >> 10)");
+
 static void set_max_drc(void)
 {
 	#define NFSD_DRC_SIZE_SHIFT	10
-	nfsd_drc_max_mem =3D (nr_free_buffer_pages()
-					>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE;
+	nfsd_drc_max_mem =3D max(drc_size,
+			       (nr_free_buffer_pages()
+				>> NFSD_DRC_SIZE_SHIFT) * PAGE_SIZE);
+	drc_size =3D nfsd_drc_max_mem;
 	nfsd_drc_mem_used =3D 0;
 	spin_lock_init(&nfsd_drc_lock);
 	dprintk("%s nfsd_drc_max_mem %lu \n", __func__, nfsd_drc_max_mem);



--O9EFGWeqDssTiUSJwphFkQNfT1NRbuIQu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBCgAGBQJVgWyEAAoJEPqBswqWsQmc5pwP/2L38N9Ifuz7ak6Q1xgmXhka
DdAH5K5evtBVya0yKb2e4nTUlEtF9uTBgasbc0QlRkLr85LafWYGxDetzJP4mV0d
7yA8KVMCz+IwPXg5pdPbv/lPBuM7vK9wWRcSIPDM5g/BfasGrvn8lqlBdP6LOfQ1
/OEDVJrysUWxdILVJ5xbjDHhgHInxOlR0fR0xAdbftKLJvQ8nwoqlmxJvbUgS5Dk
dmBLHdQIrUDFVcZDSEzFC/2exIM4k6+wt7cbeCIzs8r7QvvMlBiJY7mxWv3ZZw55
xGzDgsTG6nXs3e60G5Lwif/eZrbMIsApiuVTXVl9vIlVFWWEjunWioFJKPY2uQWW
/Mu5B9sgu/2D+leCz4nBaJwzgmcZnt4hydfHHNseXuOLhbH1FqIDz6Se60/R/G02
0k4T0SJjPBjhFaPqHIesaTznZEcQ49nUmcnZ6LOm++ysJwJIuvOQL7pSCWq8f8lh
ZBEtpoGfS3Uih0HZ2ZsSmyRkH9SwHNQJK8gYEGmJ5b4lgMkChHneSVSH6IBsX9kW
VEc0Te0oJmcbajc0tV9Lrr/jZrWF7bzIrG+vVqs+27/R6wRfMJbXKXkHMU5c6zDz
cLyRxZJzfdXxN0T4/mIJIIyYaCLa+oogOSti+x6FH5FT9qaAvXTlFIzc6qhO7QFd
mtVCG7iCJt5QNpuUrfjf
=ZTiw
-----END PGP SIGNATURE-----

--O9EFGWeqDssTiUSJwphFkQNfT1NRbuIQu--
