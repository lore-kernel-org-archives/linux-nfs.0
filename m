Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:41885 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754913Ab2HIQSA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Aug 2012 12:18:00 -0400
Received: from [192.168.100.111] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id q79GI0pb023291
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Thu, 9 Aug 2012 09:18:00 -0700
Message-ID: <5023E2B8.4060307@candelatech.com>
Date: Thu, 09 Aug 2012 09:18:00 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Kernel 3.5.0 and user-space crash in closedir
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

I've a strange issue...on the 3.5 kernel (patched with my own hacks, including
some nfs stuff), I see user-space crashes in closedir().  Apparently due to
memory corruption in glibc.

I ran under valgrind and detect no errors.

I cannot reproduce the bug on 3.3.x kernels (with similar hacks applied).


I am curious if anyone has seen anything similar.


Program terminated with signal 11, Segmentation fault.
#0  0x0000003c5ea7ea64 in _int_free (av=0x3c5edb1700, p=0x374e4b0, have_lock=0)
     at malloc.c:4097
4097		unlink(av, nextchunk, bck, fwd);
(gdb) bt
#0  0x0000003c5ea7ea64 in _int_free (av=0x3c5edb1700, p=0x374e4b0, have_lock=0)
     at malloc.c:4097
#1  0x0000003c5eab957d in __closedir (dirp=<optimized out>)
     at ../sysdeps/unix/closedir.c:52


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

