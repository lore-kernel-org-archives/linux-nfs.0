Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:42353 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734Ab0IBWgk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Sep 2010 18:36:40 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id o82Madir016665
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 2 Sep 2010 15:36:39 -0700
Message-ID: <4C8026F7.10202@candelatech.com>
Date: Thu, 02 Sep 2010 15:36:39 -0700
From: Ben Greear <greearb@candelatech.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: bug in match_ipaddr6 ?
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

static int nfs_sockaddr_match_ipaddr6(const struct sockaddr *sa1,
				      const struct sockaddr *sa2)
{
	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;

	if (ipv6_addr_scope(&sin1->sin6_addr) == IPV6_ADDR_SCOPE_LINKLOCAL &&
	    sin1->sin6_scope_id != sin2->sin6_scope_id)
		return 0;

	return ipv6_addr_equal(&sin1->sin6_addr, &sin1->sin6_addr);

Looks like this last line, second argument should be &sin2->sin6_addr ???

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

