Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:16046 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750796AbcIIFgL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Sep 2016 01:36:11 -0400
From: "Fu, Yong" <yong.fu@intel.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFS write throughput not constant 
Date: Fri, 9 Sep 2016 05:34:54 +0000
Message-ID: <E55525BD360D9249AC15FA039225DF5F2F2481A0@SHSMSX101.ccr.corp.intel.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,
I have some test on 10Gbe against NFS-based storage recently, and found the throughput of writing was not constant, the performance of writing drop down periodically.
My nfs client(version 3 and version 4 all tried) resident CentOS 6.6(2.6.32-504.el6.x86_64), NFS server is OpenMediaVault(5 ssd with stripe)

On a single mount point(or single nfs client), the avg throughput only can reach 430 MB/s, and two nfs clients aggregation can reach 700 MB/s, I can see there is periodical drop of network traffic graph both client and server side, and I am sure it's a nfs issue by lots of other tests.

I also found the nfs client commit procedure happened at the time that writing performance also dropped, and I have read B7 section(http://nfs.sourceforge.net) and think the relationship between them,  but no many ideas,  can someone help me pinpoint the root cause of this issue?

