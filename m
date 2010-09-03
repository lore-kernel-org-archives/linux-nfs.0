Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:36157 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753968Ab0ICS63 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Sep 2010 14:58:29 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o83IwSxd017054
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 3 Sep 2010 11:58:28 -0700
Message-ID: <4C814554.1000800@candelatech.com>
Date: Fri, 03 Sep 2010 11:58:28 -0700
From: Ben Greear <greearb@candelatech.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Bug with O_DIRECT in 2.6.36-rc3?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I was getting ENOMEM errors on write when using O_DIRECT in 2.6.36-rc3 plus the
patch I just posted for srcaddr= (my test harness needs that feature to work).

It seems to work fine w/out O_DIRECT enabled.

The same patch against 2.6.34.6 works fine with and without O_DIRECT.

After the ENOMEM, I cannot un-mount, even with -f (says it's busy).

But, fuser doesn't show any users.

Anyone tried O_DIRECT recently?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

