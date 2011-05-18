Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:53445 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932763Ab1ERLyy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 May 2011 07:54:54 -0400
From: <Taousif_Ansari@DELLTEAM.com>
To: <linux-nfs@vger.kernel.org>
Date: Wed, 18 May 2011 17:24:45 +0530
Subject: Performance Issue with multiple dataserver
Message-ID: <A1A98FD909DC5248811A65C5D18E9C761DF69B1F18@BLRX7MCDC202.AMER.DELL.COM>
References: <4DD2A084.1040905@moving-picture.com>
 <20110518080106.1159c5b8@notabene.brown>
 <4DD39D39.7010805@moving-picture.com>
In-Reply-To: <4DD39D39.7010805@moving-picture.com>
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I have done pNFS setup with single Dataserver and Two Dataserver and ran the IOzone tool on both, I found that the performance with multiple dataservers is less than the performance with single dataservers.

Here are some numbers, which were captured by the IOzone tool.


							  4	  8	 16	 32	 64	 128	 256	 512	1024	<== Record Length in KB
With Single Dataserver:
Read operation for file size 1 MB-		66415	66359	63630	70358	86223	70256	66047	66068	68489	<== IO kB/sec
Write operation for file size 1 MB-		18827	16920	18846	17039	18896	17009	17173	19206	17947	<== IO kB/sec

With Two Dataservers :
Read operation for file size 1 MB-		36882	381198	38150	38084	38749	33663	34398	37313	37847	<== IO kB/sec
Write operation for file size 1 MB-		5461	4661	5586	4870	5227	4922	4214	5572	4658	<== IO kB/sec


Can somebody tell me What could be the issue....
