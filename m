Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from krichy.tvnetwork.hu ([109.61.101.194]:49286 "EHLO
	krichy.tvnetwork.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759891AbcAKPHV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Jan 2016 10:07:21 -0500
Received: from localhost (localhost [127.0.0.1])
	by krichy.tvnetwork.hu (Postfix) with ESMTP id CAEFD74079
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jan 2016 16:00:19 +0100 (CET)
Date: Mon, 11 Jan 2016 16:00:19 +0100 (CET)
From: krichy@tvnetwork.hu
To: linux-nfs@vger.kernel.org
Subject: xen domU disk on nfs shared file (fwd)
Message-ID: <alpine.DEB.2.20.1601111559120.8097@krichy.tvnetwork.hu>
MIME-Version: 1.0
Content-Type: multipart/mixed; BOUNDARY="1030603365-419232731-1452520724=:24727"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--1030603365-419232731-1452520724=:24727
Content-Type: text/plain; FORMAT=flowed; CHARSET=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.20.1601111458551.24727@krichy.tvnetwork.hu>

Dear all,

We are facing a regular lockup with our xen setup. We have an nfs share mounted 
on the xen dom0, where the vm images are served, and those files are given to 
xen domUs.

I was just preparing an experiment, where I created a 100G file on the host:
# truncate -s 100G /srv/nfs/domU/disk2
And after added this disk to the instance's configuration.

On the host this is the mountpoint:
# mount|grep srv/xen
10.1.1.1:/mnt/main/vps on /srv/xen type nfs 
(rw,relatime,vers=3,rsize=16384,wsize=16384,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=10.1.1.1,mountvers=3,mountport=4045,mountproto=udp,local_lock=none,addr=10.1.1.1)

After starting the instance I partitioned the disk with gdisk, and created an 
xfs fs on it. While the fs has been created well, strange messages appeared on 
the console:

[   23.787504] blk_update_request: I/O error, dev xvdc, sector 2048
[   23.788904] blk_update_request: I/O error, dev xvdc, sector 8390655
[   23.789611] blk_update_request: I/O error, dev xvdc, sector 16779262
[   23.790359] blk_update_request: I/O error, dev xvdc, sector 25167869
[   23.791148] blk_update_request: I/O error, dev xvdc, sector 33556476
[   23.791498] blk_update_request: I/O error, dev xvdc, sector 41945083
[   23.791498] blk_update_request: I/O error, dev xvdc, sector 50333690
[   23.791498] blk_update_request: I/O error, dev xvdc, sector 58722297
[   23.791498] blk_update_request: I/O error, dev xvdc, sector 67110904
[   23.791498] blk_update_request: I/O error, dev xvdc, sector 75499511

I dont think that this is normal. If I chose a local block device (probably 
lvm) for the domU, this does not appear.

The host is running xen-4.4 with 3.16.0-4-amd64 kernel (debian jessie stock), 
the domU is running 4.3.0-0.bpo.1-amd64 (jessie backport, 4.4.4).

I suspect those messages should not be there.

Regards,

Kojedzinszky Richárd
Euronet Magyarorszag Informatika Zrt.
--1030603365-419232731-1452520724=:24727--
