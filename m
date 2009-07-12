Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx30.mail.ru ([94.100.176.44]:16803 "EHLO mx30.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbZGLEiK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 12 Jul 2009 00:38:10 -0400
From: Andrey Borzenkov <arvidjaar@mail.ru>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: How to monitor Linux NFS client load?
Date: Sun, 12 Jul 2009 08:38:02 +0400
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
References: <200907112103.27082.arvidjaar@mail.ru> <1247352267.7281.2.camel@heimdal.trondhjem.org>
In-Reply-To: <1247352267.7281.2.camel@heimdal.trondhjem.org>
Content-Type: multipart/signed;
  boundary="nextPart4227050.kbD4j8JChD";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Message-Id: <200907120838.06766.arvidjaar@mail.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--nextPart4227050.kbD4j8JChD
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sunday 12 of July 2009 02:44:27 Trond Myklebust wrote:
> On Sat, 2009-07-11 at 21:03 +0400, Andrey Borzenkov wrote:
> > Recently we have the case of very high latencies on NFS reads as
> > reported by application (SAP R/3). NFS server was NetApp FAS;
> > according to NetApp statistic, average volume read latencies were
> > in order 10ms, while SAP stats gave 30-50ms. Systems were
> > interconnected by dedicated 1Gb/s Cisco switches (3750G) with ca.
> > 30% max load on interfaces.
> >
> > On advice of my colleague we changed sunrpc.tcp_slot_table_entries
> > from default 16 to 128 which seemed to make situation much better -
> > without changing load pattern of filer in any visible way.
> >
> > Now, I can understand, why we observed much higher latency on
> > system and why changing (what effectively is) queue depth helped.
> > But I am totally frustrated that there does not appear to be *any*
> > possibility to detect this situation on Linux side and to get a
> > real numbers of real NFS IO latencies or number of requests waiting
> > to be executed (and I do not even dream about per-mount point
> > stats).
> >
> > I am grateful for any hints how can we monitor Linux NFS client and
> > get real-life numbers of what happens inside. Thank you!
>
> See the nfs-iostat utility in the nfs-utils package:
>
> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=blob;f=tools/nfs-i
>ostat/nfs-iostat.py;h=9626d42609b9485c7fda0c9ef69d698f9fa929fd;hb=HEAD
>

This looks exactly like what is required, except ...

cn1:~ # ./nfs-iostat.py 2
Traceback (most recent call last):
  File "./nfs-iostat.py", line 559, in ?
    iostat_command(prog)
  File "./nfs-iostat.py", line 464, in iostat_command
    mountstats = parse_stats_file('/proc/self/mountstats')
  File "./nfs-iostat.py", line 434, in parse_stats_file
    f = file(filename)
IOError: [Errno 2] No such file or directory: '/proc/self/mountstats'

Which minimum kernel version is required for it?

Thank you!

--nextPart4227050.kbD4j8JChD
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAkpZaKoACgkQR6LMutpd94wFiwCfY3lVJRKaejUoj5rQZBSkOQhd
8F4AoKUIm+ZyHFdo0caRzC6aCaAmn5FZ
=6Z4A
-----END PGP SIGNATURE-----

--nextPart4227050.kbD4j8JChD--
