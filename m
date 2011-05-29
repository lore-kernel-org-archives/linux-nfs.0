Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from snippy.nobiscuit.com ([50.17.199.227]:42611 "EHLO
	snippy.nobiscuit.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258Ab1E2Ncs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 09:32:48 -0400
Date: Sun, 29 May 2011 13:25:15 +0000
From: Nigel Roberts <nigel@nobiscuit.com>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 server on ARM
Message-ID: <20110529132515.GB19451@snippy.nobiscuit.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've run into a problem with running an nfsv4 server on a Marvell
Kirkwood (armv5tel) platform. When copying a large file (>1GB) to 
the NFS  server, thewrite speed will suddenly slow down to ~750kB/s 
and the CPU wait will jump to 100% for the remainder of the transfer.

Other important points:

* it doesn't happen on nfsv3 or any other protocol or indeed any other 
I/O that I have tried.
* other I/O works fine on the server while this is happening.
* the next operation will work normally unless it runs into the same 
problem again after starting out ok.
* the server is running Debian testing (ARM) and kernel 2.6.39. I've 
tried 2.6.38 and 2.6.32 and they have the same problem.
* I'm using gss/krb5i for the mounts
* it doesn't seem to affect x86_64 servers running the same kernel
version and distribution.

Here is what vmstat 1 shows just as the problem occurs:

procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 0  0      0   2828  44044 169100    0    0     0 35924 2931 2661  0 86 12  2
 2  1      0   3084  44044 168656    0    0     0  5156 2744 4684  0 47 53  0
 2  0      0   2876  44048 169144    0    0     0    34 2804 5185  0 37 55  8
 1  0      0   3072  44048 168740    0    0     0     0 3068 5870  0 39 61  0

All normal upto this point and it may stay this way for 100s of MB, 
but then things go pear-shaped:

 0  1      0   3732  44092 167768    0    0     0 16486 1162 3489  0 31 4 65
 0  1      0   3252  44188 168184    0    0     0   728  423  481  0  1 0 99
 0  1      0   2728  44264 168632    0    0     0   784  426  509  0  0 0 100
 0  1      0   2968  44316 168540    0    0     0   728  394  489  0  0 0 100
 0  1      0   3300  44396 168220    0    0     0   784  422  517  0  0 0 100

Does anyone have any ideas what might cause this and how I can help to
get it fixed?

Regards,
Nigel
