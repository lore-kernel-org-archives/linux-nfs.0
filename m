Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45945 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab1FGQyG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2011 12:54:06 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p57Gs5w0013279
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 7 Jun 2011 09:54:05 -0700
Message-ID: <4DEE57AD.8050408@candelatech.com>
Date: Tue, 07 Jun 2011 09:54:05 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: What RPM meets the libgssapi requirement on Fedora?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

./configure
....
checking pkg-config is at least version 0.9.0... yes
checking for RPCSECGSS... yes
checking for GSSAPI... configure: error: Package requirements (libgssapi >= 0.11) were not met:

No package 'libgssapi' found

I tried:

[root@fs3 linux-2.6.38.x64-dbg]# yum install libgssapi-devel
Loaded plugins: presto, refresh-packagekit
Setting up Install Process
Nothing to do

This is on Fedora 13...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

