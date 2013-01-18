Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:36369 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab3ARXjv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 18:39:51 -0500
Received: from [192.168.100.226] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0INdpdk016136
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 18 Jan 2013 15:39:51 -0800
Message-ID: <50F9DD47.707@candelatech.com>
Date: Fri, 18 Jan 2013 15:39:51 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Possible 'prev' leakage in nfs41_walk_client_list
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[ A private conversation resulted in a 'if you can't show the problem in a real test case,
then we don't need a patch' response, so I'm posting publicly in case someone
else wants to cook up a patch. ]


While looking at the code, I noticed that the nfs40 version has some code to
release 'prev' in the failure case, but nfs41 version does not.

The code is complicated, but I believe prev can indeed leak in
this method, if the failure case code path is taken.  I have no proof
that the failure case is ever taken, but the 'nfs40' version
failure case can...

Perhaps someone more familiar with this code can cook up
a fix.

I'm not using this code in my test right now, so I have
no good way to test a patch at this point.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

