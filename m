Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:40376 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752765Ab2F0Rqn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2012 13:46:43 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q5RHkgO3014908
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2012 10:46:42 -0700
Message-ID: <4FEB4702.3070700@candelatech.com>
Date: Wed, 27 Jun 2012 10:46:42 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: nfsutils compile failure (NSM_DEFAULT_STATEDIR)
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I just rebased against upstream nfs-utils:

git://git.linux-nfs.org/projects/steved/nfs-utils.git

and it fails to build on Fedora 13 (and maybe others, haven't tried yet).

gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I/usr/include/tirpc -D_GNU_SOURCE -Wall -Wextra -Wstrict-prototypes  -pipe -g -O2 -MT file.o -MD -MP -MF 
.deps/file.Tpo -c -o file.o file.c
file.c:97: error: ‘NSM_DEFAULT_STATEDIR’ undeclared here (not in a function)

Any idea on the proper way to go about fixing this?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


