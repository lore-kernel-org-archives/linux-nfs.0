From: Timo Reimann <mailinglist-d4LLFNs4DFRA7UZ8SB9NFg@public.gmane.org>
Subject: mountd prevents spindown of non-exported disk
Date: Wed, 20 Feb 2008 22:52:25 +0100
Message-ID: <47BCA119.2030404@foo-lounge.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from server3.hostprice.de ([213.239.211.250]:60480 "EHLO
	server3.hostprice.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761244AbYBTWPX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2008 17:15:23 -0500
Received: from [192.168.0.3] (dslb-088-067-245-087.pools.arcor-ip.net [88.67.245.87])
	by server3.hostprice.de (Postfix) with ESMTP id 059182DC0ED
	for <linux-nfs@vger.kernel.org>; Wed, 20 Feb 2008 22:52:26 +0100 (CET)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I have two disks in my server, one of them (hda) being used for backups
solely. To reduce noise level and power consumption, I have been trying
to keep it running in standby mode (as opposed to active) most of the time.

Although there should be nothing accessing the disk except my custom
backup cron job initiating at 5am daily, something was constantly
bringing it back into active state after a rough 20-25 minutes. With the
help of blktrace, I monitored every single I/O access to the disk and
found a single process only that would cause the wake-up:


$ sudo blkparse -i hda.blktrace.0
Input file hda.blktrace.0 added
[...]
  3,0    0        6    88.950000000  6806  Q   R 447 + 8 [rpc.mountd]
[...]


So for some reason, rpc.mountd issues this disk request in regular
intervals although nothing on the disk is being NFS-exported according
to /etc/exports.

mountd in debug mode did not yield anything further, so I did another
run with mountd hooked up to strace, and found out that the requests
happen when I NFS-mount my other drive on the server (sda), or if it's
already mounted, access files on sda (read: not hda). I assume the
spinup event can be pinpointed down to calls to stat64 or open on hda:

  open("/dev/mapper/backup-backup1", O_RDONLY) = 12

I should mention at this point that both disks have their partitions set
up facilitating LVM2, and additionally use encryption layers through
dm-crypt/LUKS on top of that. However, both sda and hda are treated in
completely separate physical volumes, respectively, not interweaved in
any way. So any access to sda should not touch hda filesystem-wise.

I'd glad if anyone could help me out by explaining why NFS operations
influence disks that are not participating in a particular operation.
Preferably with a solution how I can have both NFS running on sda and
keep hda asleep unintermittedly.

By the way, I'm using NFSv3.


Cheers,

--Timo
