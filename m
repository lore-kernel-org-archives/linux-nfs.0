Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail2.candelatech.com ([208.74.158.173]:52916 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbaGaSFt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jul 2014 14:05:49 -0400
Received: from [192.168.100.236] (firewall.candelatech.com [70.89.124.249])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 7226440AB5B
	for <linux-nfs@vger.kernel.org>; Thu, 31 Jul 2014 11:00:35 -0700 (PDT)
Message-ID: <53DA8443.407@candelatech.com>
Date: Thu, 31 Jul 2014 11:00:35 -0700
From: Ben Greear <greearb@candelatech.com>
MIME-Version: 1.0
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Killing process in D state on mount to dead NFS server.
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So, this has been asked all over the interweb for years and years, but
the best answer I can find is to reboot the system or create a fake NFS
server somewhere with the same IP as the gone-away NFS server.

The problem is:

I have some mounts to an NFS server that no longer exists (crashed/powered down).

I have some processes stuck trying to write to files open on these mounts.

I want to kill the process and unmount.

umount -l will make the mount go a way, sort of.  But process is still hung.
umount -f complains:
  umount2:  Device or resource busy
  umount.nfs: /mnt/foo: device is busy

kill -9 does not work on process.


Aside from bringing a fake NFS server back up on the same IP, is there any
other way to get these mounts unmounted and the processes killed without
rebooting?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

