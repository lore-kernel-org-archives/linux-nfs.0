Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45471 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754259Ab1FGVHu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 17:07:50 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p57L7nvI001357
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Jun 2011 14:07:49 -0700
Message-ID: <4DEE9324.8030703@candelatech.com>
Date: Tue, 07 Jun 2011 14:07:48 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: Question on passing extra argument to kernel.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On stock Fedora 13, you can add extra options to mount (srcaddr=1.2.3.4)
and if you patch the kernel to parse it, then all works well
(mount and/or mount.nfs just passes the options directly to the
kernel it seems.)

With the git://git.infradead.org/users/steved/nfs-utils.git tree,
mount.nfs errors out with 'bad option'.

What is the preferred way to go about adding new options?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

