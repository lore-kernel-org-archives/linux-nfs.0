Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:38432 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418Ab2F0SCx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2012 14:02:53 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q5RI2rHm016152
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2012 11:02:53 -0700
Message-ID: <4FEB4ACD.8030307@candelatech.com>
Date: Wed, 27 Jun 2012 11:02:53 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: nfsutils compile failure (NSM_DEFAULT_STATEDIR)
References: <4FEB4702.3070700@candelatech.com>
In-Reply-To: <4FEB4702.3070700@candelatech.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/27/2012 10:46 AM, Ben Greear wrote:
> I just rebased against upstream nfs-utils:
>
> git://git.linux-nfs.org/projects/steved/nfs-utils.git
>
> and it fails to build on Fedora 13 (and maybe others, haven't tried yet).
>
> gcc -DHAVE_CONFIG_H -I. -I../../support/include  -I/usr/include/tirpc -D_GNU_SOURCE -Wall -Wextra -Wstrict-prototypes  -pipe -g -O2 -MT file.o -MD -MP -MF
> .deps/file.Tpo -c -o file.o file.c
> file.c:97: error: ‘NSM_DEFAULT_STATEDIR’ undeclared here (not in a function)
>
> Any idea on the proper way to go about fixing this?

Maybe the issue is that 'make distclean' didn't remove the configure file.

When I tried to re-generate the configure file, it blew up because
my libgssglue is too old.  So, I'm just going to back all of this out
and go back to the old code since I need to compile back to Fedora 8
currently.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com



