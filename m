From: Ben Greear <greearb@candelatech.com>
Subject: Where is the nfs-utils source code repository?
Date: Fri, 16 Jan 2009 10:57:47 -0800
Message-ID: <4970D8AB.60409@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35398 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937143AbZAPTLV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Jan 2009 14:11:21 -0500
Received: from [192.168.100.194] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n0GIvlIZ004803
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 16 Jan 2009 10:57:48 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm trying to do some development to allow binding to a local
IP address when mounting an NFS file server, but I cannot find
an nfs-utils git repository that works.  Based on the 1.1.4 package
README, this should work:

git clone git://linux-nfs.org:/nfs-utils


But, no luck:

[greearb@fs2 tmp]$ git clone git://linux-nfs.org/nfs-utils
Initialized empty Git repository in /home/greearb/tmp/nfs-utils/.git/
fatal: The remote end hung up unexpectedly
fetch-pack from 'git://linux-nfs.org/nfs-utils' failed.

Anyone know of a working git repo for the latest nfs-utils
package?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

