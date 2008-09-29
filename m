From: Just Marc <marc-ZTWYIuj8JqNeoWH0uzbU5w@public.gmane.org>
Subject: lockd using up 60% CPU and won't let go
Date: Mon, 29 Sep 2008 12:46:15 -0400
Message-ID: <48E10657.7020503@corky.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from corky.net ([212.150.53.130]:35041 "EHLO zebday.corky.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751772AbYI2Qz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Sep 2008 12:55:27 -0400
Received: from zebday.corky.net (zebday [127.0.0.1])
	by zebday.corky.net (Postfix) with ESMTP id 17D6990597
	for <linux-nfs@vger.kernel.org>; Mon, 29 Sep 2008 19:46:17 +0300 (IDT)
Received: from [127.0.0.1] (zebday [127.0.0.1])
	by zebday.corky.net (Postfix) with ESMTP id A0083905B2
	for <linux-nfs@vger.kernel.org>; Mon, 29 Sep 2008 19:46:16 +0300 (IDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi everyone,

Doing a seemingly innocent operation such as opening a file with vim on 
a CFS (yes, that old crypto file system) NFS mount, lockd would wake up 
and take 60% of my CPU away - probably doing nothing important but 
certainly keeping the CPU busy, forever.

I use kernel 2.6.26 and kernel NFS.   Some detail is available below:
 
$ grep nfs /proc/mounts
nfsd /proc/fs/nfsd nfsd rw 0 0localhost:/var/lib/cfs/.cfsfs /var/cfs nfs 
rw,vers=2,rsize=8192,wsize=8192,namlen=255,hard,intr,proto=udp,timeo=11,retrans=3,sec=sys,addr=127.0.0.1 
0 0
localhost:/var/lib/cfs/.cfsfs/x /var/cfs/x nfs 
rw,vers=2,rsize=8192,wsize=8192,namlen=255,hard,intr,proto=udp,timeo=11,retrans=3,sec=sys,addr=127.0.0.1 
0 0

$ egrep 'NFS|_LOCKD' .config
CONFIG_LOCKDEP_SUPPORT=y
CONFIG_NFS_FS=y
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
CONFIG_NFSD_V4=y
CONFIG_ROOT_NFS=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y

I noticed this a few weeks ago but I don't quite know what causes it but 
I certainly know how to trigger it.   Stopping CFS and NFS completely 
doesn't help - as soon as NFS is restarted lockd starts eating CPU again 
just like before.

I'd appreciate any hints on what I can do to find the root cause of the 
problem and help get this bug out of the way.

Best,
Marc

