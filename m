From: Ben Greear <greearb@candelatech.com>
Subject: Reading NFS file without copying to user-space?
Date: Fri, 04 Sep 2009 12:48:53 -0700
Message-ID: <4AA16F25.6050700@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:54162 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934085AbZIDUTn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 16:19:43 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n84Jmr5m021515
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 4 Sep 2009 12:48:53 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm trying to optimize a tool that should do NFS reads as fast as possible
from a server in order to stress test the server.

Currently, I open the file as normal and read into a pre-allocated buffer.

This causes a copy of the data to user-space.

Is there any way to cause the nfs client logic to still request the file-read,
but not actually copy anything to user-space?

Maybe some trick with mmap would do this?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

