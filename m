From: David Liontooth <lionteeth-tj7FKCIresWsTnJN9+BGXg@public.gmane.org>
Subject: No write access with recent versions of nfs-utils in Debian
Date: Sun, 30 Nov 2008 14:13:49 -0800
Message-ID: <4933101D.9000308@cogweb.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from weber.sscnet.ucla.edu ([128.97.42.3]:46466 "EHLO
	weber.sscnet.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753839AbYK3WrK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 30 Nov 2008 17:47:10 -0500
Received: from localhost (localhost [127.0.0.1])
	by weber.sscnet.ucla.edu (8.14.2/8.14.2) with ESMTP id mAUMDuwS019865
	for <linux-nfs@vger.kernel.org>; Sun, 30 Nov 2008 14:13:56 -0800 (PST)
Received: from weber.sscnet.ucla.edu ([127.0.0.1])
 by localhost (weber [127.0.0.1]) (amavisd-new, port 10024) with LMTP
 id 29584-07 for <linux-nfs@vger.kernel.org>;
 Sun, 30 Nov 2008 14:13:56 -0800 (PST)
Received: from TimTi-2.local (ip8061f559.host.ucla.edu [128.97.245.89])
	by weber.sscnet.ucla.edu (8.14.2/8.14.2) with ESMTP id mAUMDo3T019817
	for <linux-nfs@vger.kernel.org>; Sun, 30 Nov 2008 14:13:51 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This appears to be a Debian-specific issue, so I'm just looking for a 
pointer from someone who may know about it.

I installed Debian sid on a new machine back in July, including the 
current nfs-common and nfs-kernel-server.  NFS mounts were successful, 
but did not allow write -- I lost some serious data on one occasion 
before I noticed the problem.  mount and nfs-utils were upgraded several 
times since, and never gave the requested write access. I've been 
assuming the problem was firewall-related and lived with it.

On the other machines in the group, NFS writes worked fine.  I banged my 
head against the wall for a while today, after finally finding time to 
look into the problem, and discovered a completely different version of 
nfs-utils was running on the new machine. After a painful downgrade 
things work fine again. 

Here's the verbose output of the version that didn't work, nfs-common  
1:1.1.3-2:

mount -vvv /mnt/cortona1
mount: fstab path: "/etc/fstab"
mount: lock path:  "/etc/mtab~"
mount: temp path:  "/etc/mtab.tmp"
mount: spec:  "cortona:/tv1"
mount: node:  "/mnt/cortona1"
mount: types: "nfs"
mount: opts:  "noauto,user,exec,rw,rsize=16k,wsize=16k,hard,intr"
mount: external mount: argv[0] = "/sbin/mount.nfs"
mount: external mount: argv[1] = "cortona:/tv1"
mount: external mount: argv[2] = "/mnt/cortona1"
mount: external mount: argv[3] = "-v"
mount: external mount: argv[4] = "-o"
mount: external mount: argv[5] = 
"rw,nosuid,nodev,noauto,user,rsize=16k,wsize=16k,hard,intr"
mount.nfs: trying xxx.xxx.xxx.178 prog 100003 vers 3 prot TCP port 2049
mount.nfs: trying xxx.xxx.xxx.178 prog 100005 vers 3 prot UDP port 32774
cortona:/tv1 on /mnt/cortona1 type nfs 
(noauto,user,exec,rw,rsize=16k,wsize=16k,hard,intr)
tna@roma$ cd /mnt/cortona1
tna@roma:/mnt/cortona1$ touch one
touch: cannot touch `one': Permission denied

Downgrading to 1:1.1.0-5 restored proper write access. Is this a 
familiar-looking problem to someone?

Dave


