Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:58048 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1422908AbcBSPjO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Feb 2016 10:39:14 -0500
Date: Fri, 19 Feb 2016 16:31:23 +0100
From: William Dauchy <william@gandi.net>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>, william@gandi.net
Subject: poor random read nfs client results using fio on v4.1.x
Message-ID: <20160219153123.GC3351@gandi.net>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eRtJSFbw+EEWtPj3"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--eRtJSFbw+EEWtPj3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I have been running a few random read using a nfsv4 client.
I used the following fio file:

; random read of 128mb of data
[random-read]
rw=3Drandread
size=3D128m
directory=3D/tmp/foo


I am using the last long term v4.1.x kernel. The results gave me very
poor performances:

random-read: (g=3D0): rw=3Drandread, bs=3D4K-4K/4K-4K/4K-4K, ioengine=3Dsyn=
c, iodepth=3D1
fio-2.1.11
Starting 1 process
Jobs: 1 (f=3D1): [r(1)] [100.0% done] [2780KB/0KB/0KB /s] [695/0/0 iops] [e=
ta 00m:00s]
random-read: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D3552: Fri Feb 19 15:2=
9:43 2016
  read : io=3D131072KB, bw=3D2826.7KB/s, iops=3D706, runt=3D 46370msec
    clat (usec): min=3D1157, max=3D10807, avg=3D1407.98, stdev=3D120.44
     lat (usec): min=3D1157, max=3D10807, avg=3D1408.31, stdev=3D120.45
    clat percentiles (usec):
     |  1.00th=3D[ 1240],  5.00th=3D[ 1256], 10.00th=3D[ 1288], 20.00th=3D[=
 1336],
     | 30.00th=3D[ 1352], 40.00th=3D[ 1368], 50.00th=3D[ 1400], 60.00th=3D[=
 1432],
     | 70.00th=3D[ 1432], 80.00th=3D[ 1464], 90.00th=3D[ 1528], 95.00th=3D[=
 1608],
     | 99.00th=3D[ 1720], 99.50th=3D[ 1784], 99.90th=3D[ 2256], 99.95th=3D[=
 2512],
     | 99.99th=3D[ 2960]
    bw (KB  /s): min=3D 2496, max=3D 3008, per=3D100.00%, avg=3D2829.38, st=
dev=3D78.92
    lat (msec) : 2=3D99.83%, 4=3D0.17%, 20=3D0.01%
  cpu          : usr=3D0.50%, sys=3D12.40%, ctx=3D65552, majf=3D0, minf=3D68
  IO depths    : 1=3D100.0%, 2=3D0.0%, 4=3D0.0%, 8=3D0.0%, 16=3D0.0%, 32=3D=
0.0%, >=3D64=3D0.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     issued    : total=3Dr=3D32768/w=3D0/d=3D0, short=3Dr=3D0/w=3D0/d=3D0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D1

Run status group 0 (all jobs):
   READ: io=3D131072KB, aggrb=3D2826KB/s, minb=3D2826KB/s, maxb=3D2826KB/s,=
 mint=3D46370msec, maxt=3D46370msec


So I gave a try with v4.4.x, but the results remains poor:

random-read: (g=3D0): rw=3Drandread, bs=3D4K-4K/4K-4K/4K-4K, ioengine=3Dsyn=
c, iodepth=3D1
fio-2.1.11
Starting 1 process
Jobs: 1 (f=3D1): [r(1)] [100.0% done] [1404KB/0KB/0KB /s] [351/0/0 iops] [e=
ta 00m:00s]
random-read: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D3649: Fri Feb 19 15:1=
7:49 2016
  read : io=3D131072KB, bw=3D1393.2KB/s, iops=3D348, runt=3D 94026msec
    clat (usec): min=3D2286, max=3D11370, avg=3D2859.12, stdev=3D446.19
     lat (usec): min=3D2286, max=3D11370, avg=3D2859.53, stdev=3D446.17
    clat percentiles (usec):
     |  1.00th=3D[ 2480],  5.00th=3D[ 2512], 10.00th=3D[ 2544], 20.00th=3D[=
 2544],
     | 30.00th=3D[ 2576], 40.00th=3D[ 2608], 50.00th=3D[ 2640], 60.00th=3D[=
 2736],
     | 70.00th=3D[ 2928], 80.00th=3D[ 3216], 90.00th=3D[ 3568], 95.00th=3D[=
 3760],
     | 99.00th=3D[ 4384], 99.50th=3D[ 4512], 99.90th=3D[ 4896], 99.95th=3D[=
 5216],
     | 99.99th=3D[ 6304]
    bw (KB  /s): min=3D 1075, max=3D 1432, per=3D100.00%, avg=3D1395.07, st=
dev=3D30.20
    lat (msec) : 4=3D97.81%, 10=3D2.18%, 20=3D0.01%
  cpu          : usr=3D0.32%, sys=3D10.39%, ctx=3D65558, majf=3D0, minf=3D36
  IO depths    : 1=3D100.0%, 2=3D0.0%, 4=3D0.0%, 8=3D0.0%, 16=3D0.0%, 32=3D=
0.0%, >=3D64=3D0.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     issued    : total=3Dr=3D32768/w=3D0/d=3D0, short=3Dr=3D0/w=3D0/d=3D0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D1

Run status group 0 (all jobs):
   READ: io=3D131072KB, aggrb=3D1393KB/s, minb=3D1393KB/s, maxb=3D1393KB/s,=
 mint=3D94026msec, maxt=3D94026msec


My previous kernel was 3.14.x, and the resuls were better:

random-read: (g=3D0): rw=3Drandread, bs=3D4K-4K/4K-4K/4K-4K, ioengine=3Dsyn=
c, iodepth=3D1
fio-2.1.11
Starting 1 process
Jobs: 1 (f=3D1): [r(1)] [100.0% done] [8980KB/0KB/0KB /s] [2245/0/0 iops] [=
eta 00m:00s]
random-read: (groupid=3D0, jobs=3D1): err=3D 0: pid=3D3655: Fri Feb 19 15:2=
2:25 2016
  read : io=3D131072KB, bw=3D9348.1KB/s, iops=3D2337, runt=3D 14020msec
    clat (usec): min=3D252, max=3D5567, avg=3D420.90, stdev=3D85.03
     lat (usec): min=3D253, max=3D5567, avg=3D421.28, stdev=3D85.02
    clat percentiles (usec):
     |  1.00th=3D[  290],  5.00th=3D[  326], 10.00th=3D[  338], 20.00th=3D[=
  354],
     | 30.00th=3D[  362], 40.00th=3D[  366], 50.00th=3D[  398], 60.00th=3D[=
  466],
     | 70.00th=3D[  482], 80.00th=3D[  490], 90.00th=3D[  516], 95.00th=3D[=
  540],
     | 99.00th=3D[  596], 99.50th=3D[  620], 99.90th=3D[  676], 99.95th=3D[=
 1096],
     | 99.99th=3D[ 1640]
    bw (KB  /s): min=3D 8704, max=3D10368, per=3D100.00%, avg=3D9352.57, st=
dev=3D579.50
    lat (usec) : 500=3D87.75%, 750=3D12.19%, 1000=3D0.01%
    lat (msec) : 2=3D0.05%, 4=3D0.01%, 10=3D0.01%
  cpu          : usr=3D3.28%, sys=3D13.75%, ctx=3D61908, majf=3D0, minf=3D36
  IO depths    : 1=3D100.0%, 2=3D0.0%, 4=3D0.0%, 8=3D0.0%, 16=3D0.0%, 32=3D=
0.0%, >=3D64=3D0.0%
     submit    : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     complete  : 0=3D0.0%, 4=3D100.0%, 8=3D0.0%, 16=3D0.0%, 32=3D0.0%, 64=
=3D0.0%, >=3D64=3D0.0%
     issued    : total=3Dr=3D32768/w=3D0/d=3D0, short=3Dr=3D0/w=3D0/d=3D0
     latency   : target=3D0, window=3D0, percentile=3D100.00%, depth=3D1

Run status group 0 (all jobs):
   READ: io=3D131072KB, aggrb=3D9348KB/s, minb=3D9348KB/s, maxb=3D9348KB/s,=
 mint=3D14020msec, maxt=3D14020msec



I would expect at least the same performances in v4.1.x.
What can I do to help debug this issue?

Thanks,
--=20
William

--eRtJSFbw+EEWtPj3
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlbHNUsACgkQ1I6eqOUidQH3PACfQaGr0KSc4TZjWTapBHVMXTnP
KXAAn0nhzWL/mDJviu6c8iTD5rst37CG
=/xvi
-----END PGP SIGNATURE-----

--eRtJSFbw+EEWtPj3--
