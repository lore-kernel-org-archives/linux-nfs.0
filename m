Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cpsmtpm-eml103.kpnxchange.com ([195.121.3.7]:65413 "EHLO
	CPSMTPM-EML103.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753993AbZGQXbP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jul 2009 19:31:15 -0400
From: Frans Pop <elendil@planet.nl>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [2.6.30.1] Significant latency playing video file from NFS4 share
Date: Sat, 18 Jul 2009 01:31:11 +0200
Cc: linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org
References: <200907172250.51504.elendil@planet.nl> <1247871086.4945.38.camel@heimdal.trondhjem.org>
In-Reply-To: <1247871086.4945.38.camel@heimdal.trondhjem.org>
Content-Type: text/plain;
  charset="utf-8"
Message-Id: <200907180131.12586.elendil@planet.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Thanks for the quick response!

On Saturday 18 July 2009, Trond Myklebust wrote:
> Have you tried running nfs-iostat from the nfs-utils package to try and
> figure out what the latency is on each READ request from the client?
>
> You need to run something like
>
>     nfs-iostat --page 20 10 /src/<mountpoint>
>
> while running the vlc app.

$ ../nfs-iostat.py --page 20 10 /srv/fjp/david

Note:
The mount point selection could be improved. I first had a trailing slash
after the mount point and that resulted in all mounts being included in the
output. Removing the slash helped.

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.65            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.406         101.661         250.613        0 (0.0%)         1211.745        1222.640
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

13 nfs_readpage() calls read 13 pages
1417 nfs_readpages() calls read 971428 pages (685.6 pages per call)

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
18760 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.25            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.100           0.426           4.262        0 (0.0%)           6.000           6.000
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

0 nfs_readpage() calls read 0 pages
2 nfs_readpages() calls read 2 pages (1.0 pages per call)

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
6 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.80            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.750         192.196         256.262        0 (0.0%)         1998.933        1999.200
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

0 nfs_readpage() calls read 0 pages
1 nfs_readpages() calls read 960 pages (960.0 pages per call)

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
6 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.00            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

0 nfs_readpage() calls read 0 pages
0 nfs_readpages() calls read 0 pages

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
6 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.85            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.750         192.196         256.262        0 (0.0%)         1927.467        1927.467
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

0 nfs_readpage() calls read 0 pages
1 nfs_readpages() calls read 960 pages (960.0 pages per call)

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
6 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.00            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

0 nfs_readpage() calls read 0 pages
0 nfs_readpages() calls read 0 pages

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
6 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.85            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.750         192.196         256.262        0 (0.0%)         1930.933        1931.467
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

0 nfs_readpage() calls read 0 pages
1 nfs_readpages() calls read 960 pages (960.0 pages per call)

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
5 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

elrond:/david mounted on /srv/fjp/david:

   op/s         rpc bklog
   0.15            0.00
read:             ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.100           0.426           4.262        0 (0.0%)           6.000           6.000
write:            ops/s            kB/s           kB/op         retrans         avg RTT (ms)    avg exe (ms)
                  0.000           0.000           0.000        0 (0.0%)           0.000           0.000

0 nfs_readpage() calls read 0 pages
2 nfs_readpages() calls read 2 pages (1.0 pages per call)

0 nfs_updatepage() calls
0 nfs_writepage() calls wrote 0 pages
6 nfs_writepages() calls wrote 0 pages (0.0 pages per call)

Cheers,
FJP
