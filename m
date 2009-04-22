From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/11] nfsd: Summary of "Improve NFS server performance"
Date: Wed, 22 Apr 2009 11:05:14 +0530
Message-ID: <OF1C0CA781.3D250575-ON652575A0.001DB832-652575A0.001EB15F@in.ibm.com>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090421225728.GI27411@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:52370 "EHLO
	e28smtp01.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753675AbZDVFfo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 01:35:44 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3M5ZeD2004330
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 11:05:40 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3M5ZpbS4227260
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 11:05:51 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3M5bIqp008258
	for <linux-nfs@vger.kernel.org>; Wed, 22 Apr 2009 11:07:19 +0530
In-Reply-To: <20090421225728.GI27411@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 04/22/2009 04:27:28 AM:

> The numbers look promising, but very noisy.  Maybe an average of a few
> tests would give more stable numbers?

Is it enough if I cut out some "popular" bufsizes and #processes out of
that
table and post it? If so, here is a smaller list:

----------------------------------------------------------------------
#Processes      Bufsize         OrgBW KB/s      New BW KB/s     %
----------------------------------------------------------------------
4               4096            60660.67        64309.37        6.01
4               16384           60796.86        64069.82        5.38
4               65536           60774.45        63735.24        4.87
4               131072          61369.66        65261.85        6.34

8               4096            50650.45        55400.01        9.37
8               16384           51114.76        56025.31        9.60
8               65536           51000.23        54285.63        6.44
8               131072          52996.73        54021.11        1.93

16              4096            43897.69        46519.89        5.97
16              16384           43883.62        46726.03        6.47
16              65536           43804.33        44865.20        2.42
16              131072          44525.30        43752.62        -1.73

32              4096            39913.14        42279.21        5.92
32              16384           38094.95        42645.32        11.94
32              65536           41438.05        41794.76        .86
32              131072          41869.06        43644.07        4.23

64              4096            35468.42        35529.29        .17
64              16384           31926.51        32694.91        2.40
64              65536           36066.08        36359.77        .81
64              131072          35969.04        37462.86        4.15

128             4096            29311.11        30097.65        2.68
128             16384           28283.58        29071.45        2.78
128             65536           32617.13        33778.46        3.56
128             131072          32972.71        34160.82        3.60

192             4096            27368.48        29318.49        7.12
192             16384           26388.54        29719.15        12.62
192             65536           33374.85        33607.14        .69
192             131072          33523.48        32601.93        -2.74
-----------------------------------------------------------------------
                                1170059.88      1223737.36      4.58%
-----------------------------------------------------------------------

Thanks,

- KK

