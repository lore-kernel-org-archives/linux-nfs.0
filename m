Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60958 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab0IHAMS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Sep 2010 20:12:18 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o880CHBX012629
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 17:12:17 -0700
Message-ID: <4C86D4E1.4000403@candelatech.com>
Date: Tue, 07 Sep 2010 17:12:17 -0700
From: Ben Greear <greearb@candelatech.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: is 'umount' asynchronous?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

While testing NFSv4 over TCPv6 on 2.6.36-rc3 + my srcaddr= patch today,
I noticed that I was getting 'busy' errors from umount if I closed a
file in a program and then had it immediately system("umount ...");

If I retry the umount a few times, it will start returning 'already unmounted'.
It took around 50-100ms (I was sleeping 50ms between umount attempts).

Is that expected behaviour?  Seems we never needed any retries and never
got 'busy' on 2.6.34 and earlier.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

