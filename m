From: Ben Greear <greearb@candelatech.com>
Subject: Possible bug in nfs-utils source.
Date: Wed, 21 Jan 2009 14:25:48 -0800
Message-ID: <4977A0EC.3050103@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33570 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753168AbZAUWZt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Jan 2009 17:25:49 -0500
Received: from [192.168.100.194] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n0LMPmiD004234
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 21 Jan 2009 14:25:49 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm working on adding support to bind to local addresses, and
I noticed this code in nfs/getport.c

I believe the sizeof should probably be sizeof(*lb_addr) ?

unsigned short nfs_getlocalport(const rpcprot_t program,
				const rpcvers_t version,
				const unsigned short protocol)
{
	struct sockaddr_storage address;
	struct sockaddr *lb_addr = (struct sockaddr *)&address;
	socklen_t lb_len = sizeof(lb_addr);
	unsigned short port = 0;

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

