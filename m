Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from outbound-smtp02.blacknight.com ([81.17.249.8]:44274 "EHLO
	outbound-smtp02.blacknight.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754002AbbEORtn convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 May 2015 13:49:43 -0400
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 932DA980C0
	for <linux-nfs@vger.kernel.org>; Fri, 15 May 2015 17:44:25 +0000 (UTC)
Subject: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN) filesystem.
Mime-Version: 1.0 (1.0)
From: Benjamin ESTRABAUD <be@mpstor.com>
Content-Type: text/plain;
	charset=us-ascii
Message-Id: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com>
Date: Fri, 15 May 2015 10:44:13 -0700
Cc: "bc@mpstor.com" <bc@mpstor.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!

I've been using pNFS for a while since recently, and I am very pleased with its overall stability and performance.

A pNFS MDS server was setup with SAN storage in the backend (a RAID0 built ontop of multiple LUNs). Clients were given access to the same RAID0 using the same LUNs on the same SAN.

However, I've been noticing a small issue with it that prevents me from using pNFS to its full potential: If I run non-direct IOs (for instance "dd" without the "oflag=direct" option), IOs run excessively slowly (3-4MB/sec) and the dd process hangs until forcefully terminated. The same behaviour can be observed laying out an IO file with FIO for instance, or using some applications which do not use the ODIRECT flag. When using direct IO I can observe lots of iSCSI traffic, at extremely good performance (same performance as the SAN gets on "raw" block devices).

All the systems are running CentOS 7.0 with a custom kernel 4.1-rc2 (pNFS enabled) apart from the storage nodes which are running a custom minimal Linux distro with Kernel 3.18.

The SAN is all 40G Mellanox Ethernet, and we are not using the OFED driver anywhere (Everything is only "standard" upstream Linux).

Would anybody have any ideas where this issue could be coming from?

Regards,
Ben - MPSTOR.