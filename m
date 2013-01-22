Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:59171 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754704Ab3AVQPF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Jan 2013 11:15:05 -0500
Received: from [50.54.140.2] (50-54-140-2.evrt.wa.frontiernet.net [50.54.140.2])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id r0MGF4Ta017109
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 22 Jan 2013 08:15:05 -0800
Message-ID: <50FEBB08.2090709@candelatech.com>
Date: Tue, 22 Jan 2013 08:15:04 -0800
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFS: Cache request denied due to non-unique superblock keys
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I saw this on an overnight run with 3000 NFSv4 mounts:

NFS: Cache request denied due to non-unique superblock keys


Any idea if it's a problem or not?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

