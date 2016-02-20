Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:54976 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758282AbcBTPw6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 20 Feb 2016 10:52:58 -0500
Date: Sat, 20 Feb 2016 16:52:54 +0100
From: William Dauchy <william@gandi.net>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, william@gandi.net
Subject: Re: poor random read nfs client results using fio on v4.1.x
Message-ID: <20160220155254.GA3225@gandi.net>
References: <20160219153123.GC3351@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="NzB8fVQJ5HfG6fxh"
In-Reply-To: <20160219153123.GC3351@gandi.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Feb19 16:31, William Dauchy wrote:
> I would expect at least the same performances in v4.1.x.
> What can I do to help debug this issue?

I overlooked my config in 4.1.x and find out KASAN and kmemleak were
enabled.
however I can't reach the results I had on 3.14.x without these debug
options.

see my updated results on 4.1.x:

random-read: (g=3D0): rw=3Drandread, bs=3D4K-4K/4K-4K/4K-4K, ioengine=3Dsyn=
c, iodepth=3D1
fio-2.1.11
Starting 1 process
Jobs: 1 (f=3D1): [r(1)] [100.0% done] [7136KB/0KB/0KB /s] [1784/0/0 iops] [=
eta 00m:00s]
random-read: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D3519: Sat Feb 20 15:4=
4:10 2016
  read : io=3D131072KB, bw=3D7617.9KB/s, iops=3D1904, runt=3D 17206msec
    clat (usec): min=3D281, max=3D2091, avg=3D517.56, stdev=3D79.68
     lat (usec): min=3D281, max=3D2092, avg=3D517.90, stdev=3D79.69
    clat percentiles (usec):
     |  1.00th=3D[  318],  5.00th=3D[  402], 10.00th=3D[  422], 20.00th=3D[=
  442],
     | 30.00th=3D[  490], 40.00th=3D[  506], 50.00th=3D[  516], 60.00th=3D[=
  524],
     | 70.00th=3D[  548], 80.00th=3D[  580], 90.00th=3D[  612], 95.00th=3D[=
  652],
     | 99.00th=3D[  716], 99.50th=3D[  740], 99.90th=3D[  772], 99.95th=3D[=
 1208],
     | 99.99th=3D[ 1624]
    bw (KB  /s): min=3D 7080, max=3D 8128, per=3D100.00%, avg=3D7627.53, st=
dev=3D343.98
    lat (usec) : 500=3D37.34%, 750=3D62.32%, 1000=3D0.28%
    lat (msec) : 2=3D0.05%, 4=3D0.01%
  cpu          : usr=3D2.05%, sys=3D14.02%, ctx=3D65541, majf=3D0, minf=3D45
  IO depths    : 1=3D100.0%, 2=3D0.0%, 4=3D0.0%, 8=3D0.0%, 16=3D0.0%, 32=3D=
0.0%, >=3D64=3D0.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     issued    : total=3Dr=3D32768/w=3D0/d=3D0, short=3Dr=3D0/w=3D0/d=3D0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D1

Run status group 0 (all jobs):
   READ: io=3D131072KB, aggrb=3D7617KB/s, minb=3D7617KB/s, maxb=3D7617KB/s,=
 mint=3D17206msec, maxt=3D17206msec


summary:
3.14: 9348KB/s
4.1:  7617KB/s

--=20
William

--NzB8fVQJ5HfG6fxh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlbIi9YACgkQ1I6eqOUidQGdNQCfVkSmuBH4rlCyqpGfmbswUHMq
/1QAn3oNJJh77FNf3DEl/JJOhFkQp7QT
=ycDT
-----END PGP SIGNATURE-----

--NzB8fVQJ5HfG6fxh--
