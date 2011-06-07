Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:45130 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752315Ab1FGAQJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2011 20:16:09 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id p570G8XL001012
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Mon, 6 Jun 2011 17:16:08 -0700
Message-ID: <4DED6DC8.8020500@candelatech.com>
Date: Mon, 06 Jun 2011 17:16:08 -0700
From: Ben Greear <greearb@candelatech.com>
To: linux-nfs@vger.kernel.org
Subject: Question on portmapper source
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

What is the official upstream project that contains the portmapper
source?

Also, the mount.nfs package, as I'll probably need to modify that
as well...

I am going to try to allow portmapper to bind to a particular
source IP when making outbound requests....

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

