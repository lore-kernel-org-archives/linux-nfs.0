Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62867 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab1IZLDS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 07:03:18 -0400
Received: from sreeramb1-lxp.hq.netapp.com (sreeramb1-lxp.hq.netapp.com [10.73.9.34])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id p8QB31Sp004518
	for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 04:03:02 -0700 (PDT)
Message-ID: <4E805C16.4030509@netapp.com>
Date: Mon, 26 Sep 2011 16:33:50 +0530
From: Sreeram B S <sreeramb@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: NFS mounts and its propagation
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,
     I am Sreeram. This question is related to NFS.
     I have a typical scenario. Please assume that there are 3 machines 
M1, M2, M3. Each of them are having directories /tmp/abc in them. All 
the NFS permissions are set appropriately.
     Now, a user mounts M2's /tmp/abc on M1's /tmp/abc by issuing mount 
command on M1. Mount is successful.
     Then the user mounts M3's /tmp/abc on M2's /tmp/abc by issuing 
mount command on M2. Mount successful.
     Now I would expect the contents of M3's /tmp/abc to be shown as 
output of 'ls' issue on M1. But this is not happening. I am unable to 
comprehend the reason. Could you please guide me?

     According to me, the contents of M3 should have shown up in M1's 
'ls' command,  because the /tmp/abc of M1 is nothing  but a *live* 
reflection of /tmp/abc of M2. So whatever changes are done to M2's 
/tmp/abc should be reflected on M1. Here, M2's /tmp/abc is mounting M3's 
/tmp/abc and so this change should be reflected on M1's /tmp/abc as 
well. But this isn't happening.

Kindly suggest if I am incorrect in my understanding or usage.
   The command I am using is:

    On M1:  mount -t nfs M2:/tmp/abc /tmp/abc
    On M2:  mount -t nfs M3:/tmp/abc /tmp/abc

Regards,
Sreeram
