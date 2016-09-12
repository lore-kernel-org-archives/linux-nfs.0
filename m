Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:49784 "EHLO smtp-o-1.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932302AbcILHEg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Sep 2016 03:04:36 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
        by smtp-o-1.desy.de (DESY-O-1) with ESMTP id C74E5280366
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2016 09:04:33 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
        by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id BA41213EB6
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2016 09:04:33 +0200 (MEST)
Date: Mon, 12 Sep 2016 09:04:33 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "Fu, Yong" <yong.fu@intel.com>
Cc: linux-nfs@vger.kernel.org
Message-ID: <1919782444.9045061.1473663873082.JavaMail.zimbra@desy.de>
In-Reply-To: <E55525BD360D9249AC15FA039225DF5F2F2481A0@SHSMSX101.ccr.corp.intel.com>
References: <E55525BD360D9249AC15FA039225DF5F2F2481A0@SHSMSX101.ccr.corp.intel.com>
Subject: Re: NFS write throughput not constant
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Can be related to flushing of dirty pages. 
How much memory do you have on the clients?

You can play with vm.dirty_background_bytes
kernel parameter to get better performance.
Linux default is 10% of the RAM
(vm.dirty_background_ratio ), which can produce
spikes on IO if too much data accumulated in
fs cache, while you, probably, smooth continues
writing.

Tigran.


----- Original Message -----
> From: "Fu, Yong" <yong.fu@intel.com>
> To: linux-nfs@vger.kernel.org
> Sent: Friday, September 9, 2016 7:34:54 AM
> Subject: NFS write throughput not constant

> Hi,
> I have some test on 10Gbe against NFS-based storage recently, and found the
> throughput of writing was not constant, the performance of writing drop down
> periodically.
> My nfs client(version 3 and version 4 all tried) resident CentOS
> 6.6(2.6.32-504.el6.x86_64), NFS server is OpenMediaVault(5 ssd with stripe)
> 
> On a single mount point(or single nfs client), the avg throughput only can reach
> 430 MB/s, and two nfs clients aggregation can reach 700 MB/s, I can see there
> is periodical drop of network traffic graph both client and server side, and I
> am sure it's a nfs issue by lots of other tests.
> 
> I also found the nfs client commit procedure happened at the time that writing
> performance also dropped, and I have read B7
> section(http://nfs.sourceforge.net) and think the relationship between them,
> but no many ideas,  can someone help me pinpoint the root cause of this issue?
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
