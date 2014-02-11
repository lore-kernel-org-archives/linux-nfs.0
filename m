Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mlbefw1.harris.com ([192.52.233.75]:57011 "EHLO
	mlbefw1.harris.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaBKMmX convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Feb 2014 07:42:23 -0500
From: "McAninley, Jason" <jmcaninl@harris.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Question regard NFS 4.0 buffer sizes
Date: Tue, 11 Feb 2014 12:32:33 +0000
Message-ID: <322949BF788C8D468BEA0A321B79799098BDB9F0@MLBMXUS20.cs.myharris.net>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm looking for detailed documentation regarding some of the innards of NFS 4.0, without necessarily having to read through the source code (if such documentation exists). 

Specifically related to the relationship between NFS's rsize/wsize options versus some of the lower-level networking buffers. Buffer parameters that I have come across (and my current settings) include:

  - sysctl's net.core.{r,w}mem_default: 229376
  - sysctl's net.core.{r,w}mem_max:     131071
  - sysctl's net.ipv4.tcp_{r,w}mem      4096 87380 4194304
  - #define RPCSVC_MAXPAYLOAD          (1*1024*1024u)

When I run Wireshark during an NFS transfer, I see MAX{READ,WRITE} attributes returned from GETATTR with the value of 1MB. I'm guessing this corresponds to the limit set by RPCSVR_MAXPAYLOAD? However, the maximum packet size I'm recording in practice is ~32K.

In fact, it seems like regardless of the change to {r,w}size (I've tried 32K, 64K, 128K) I am not seeing changes in the max packet size.

This is leading me to investigate the buffer sizes on the client/server. My thought is that if a buffer exists that is too small, NFS/Kernel will ship a packet prior to reaching the MAXWRITE size. 

Any input is appreciated.

-Jason
