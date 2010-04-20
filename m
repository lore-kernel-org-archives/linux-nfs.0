From: "Arce, Abraham" <x0066660@ti.com>
Subject: Kernel crash while task blocked
Date: Tue, 20 Apr 2010 11:03:05 -0500
Message-ID: <27F9C60D11D683428E133F85D2BB4A53043DB93399@dlee03.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:34175 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab0DTQDI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Apr 2010 12:03:08 -0400
Received: from dlep36.itg.ti.com ([157.170.170.91])
	by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id o3KG37jH011675
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 20 Apr 2010 11:03:07 -0500
Received: from dlep26.itg.ti.com (localhost [127.0.0.1])
	by dlep36.itg.ti.com (8.13.8/8.13.8) with ESMTP id o3KG36uD019062
	for <linux-nfs@vger.kernel.org>; Tue, 20 Apr 2010 11:03:06 -0500 (CDT)
Received: from dlee73.ent.ti.com (localhost [127.0.0.1])
	by dlep26.itg.ti.com (8.13.8/8.13.8) with ESMTP id o3KG36lK017603
	for <linux-nfs@vger.kernel.org>; Tue, 20 Apr 2010 11:03:06 -0500 (CDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

I am working with 
 - KS8851 SPI based ethernet controller (drivers/net/ks8851.c)
 - my filesystem is over nfs
 - using common nfs bootargs (nolock,tcp,rsize=8092,wsize=8092)
 - kernel version is 2.6.33-rc2

While doing some tests using dd (20 instances of it) creating a 10 MB file each,

  # dd if=/dev/urandom of=/file.temp.00 bs=1M count=10 &
  # dd if=/dev/urandom of=/file.temp.01 bs=1M count=10 &
  ...

I got the following crash,

  INFO: task dd:516 blocked for more than 120 seconds.
  "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
  dd            D c0284154     0   516    495 0x00000000
  Backtrace:
  [<c0283a9c>] (schedule+0x0/0x7c0)
  [<c0284a28>] (__mutex_lock_slowpath+0x0/0x1e4)
  [<c0284c0c>] (mutex_lock+0x0/0x3c)
  [<c0085b7c>] (generic_file_aio_write+0x0/0xd4)
  [<c0134d30>] (nfs_file_write+0x0/0x1b8)
  [<c00b0d5c>] (do_sync_write+0x0/0xe8)
  [<c00b17fc>] (vfs_write+0x0/0x164)
  [<c00b19e0>] (sys_write+0x0/0x70)
  [<c002d140>] (ret_fast_syscall+0x0/0x2c)

I have repeated same tests several times but not seen frequently, any idea to debug will be highly appreciated.

Best Regards
Abraham
