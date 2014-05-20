Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout04.kla-tencor.com ([192.146.1.174]:60831 "EHLO
	ca1mailout01.kla-tencor.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751216AbaETINz convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 May 2014 04:13:55 -0400
Received: from pps.filterd (ca1mailout01 [127.0.0.1])
	by ca1mailout01.kla-tencor.com (8.14.4/8.14.4) with SMTP id s4K8Dm5a007086
	for <linux-nfs@vger.kernel.org>; Tue, 20 May 2014 01:13:54 -0700
Received: from ca1vmexcahu02.adcorp.kla-tencor.com (mailserver.kla-tencor.com [10.39.10.202])
	by ca1mailout01.kla-tencor.com with ESMTP id 1kyrsfgwma-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-nfs@vger.kernel.org>; Tue, 20 May 2014 01:13:54 -0700
From: "Subramanian, Parthiban" <Parthiban.Subramanian@kla-tencor.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Reg. setup of pnfs.
Date: Tue, 20 May 2014 08:13:52 +0000
Message-ID: <8f2a8466e744435a99e76d84c926696e@SN2PR03MB048.namprd03.prod.outlook.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Team,

I'm new to pnfs, have gone through about pnfs performance and wanted to adopt the technique, I have gone through the setup page for the pnfs setup, but not able to get the complete picture of the whole setup will look like, I have the following queries and if any of you can help me it would be great.

1.	Our functional requirement is like this; a large file stored in an data server has to be distributed to the compute nodes and get the computation done, hence will the pnfs will suite out requirement?
2.	How to setup the MDS? And how the maps for file will be created? 
3.	Is it mandatory to use GFS for file layout?

I have gone through the pnfs wiki, but since the MDS setup is not clear not able to get setup.

Kindly help! Apologies if the questions are lame!

Thanks,
Parthiban
