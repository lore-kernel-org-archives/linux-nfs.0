From: Eric Paris <eparis@redhat.com>
Subject: 2.6.24-rc3 unable to mount something which should use nohide
Date: Thu, 29 Nov 2007 11:44:59 -0500
Message-ID: <1196354699.2912.57.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58405 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759314AbXK2QpF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 Nov 2007 11:45:05 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lATGj5F6029114
	for <linux-nfs@vger.kernel.org>; Thu, 29 Nov 2007 11:45:05 -0500
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lATGj4qo017927
	for <linux-nfs@vger.kernel.org>; Thu, 29 Nov 2007 11:45:04 -0500
Received: from [10.11.15.96] (vpn-15-96.rdu.redhat.com [10.11.15.96])
	by pobox.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lATGixXE004269
	for <linux-nfs@vger.kernel.org>; Thu, 29 Nov 2007 11:45:00 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFS server "paris" (some 2.6.18 based kernel):

[root@paris ~]# mount | grep storage
/dev/mapper/StorageVG01-LogVol00 on /export/storage type ext3 (rw)
/dev/mapper/KernelVG01-LogVol00 on /export/storage/kernel type ext3 (rw)
[root@paris ~]# cat /etc/exports
/export/storage         *(rw,sync,all_squash,anonuid=500,anongid=500)
/export/storage/kernel  *(rw,sync,all_squash,anonuid=500,anongid=500,nohide)

On my clients x86_64 running an almost clean-from-git 2.6.24-rc3 kernel:

[root@dhcp231-145 ~]# mount -o noatime paris:/export/storage /storage
[root@dhcp231-145 ~]# ls /storage/kernel
ls: cannot access /storage/kernel: Stale NFS file handle

(notice /storage/kernel should be triggering that nohide mount
for /export/storage/kernel) so I figured maybe that automatic nohide
stuff was broken.  I'll try by hand:

[root@dhcp231-145 ~]# mount paris:/export/storage/kernel /storage/kernel
mount.nfs: Stale NFS file handle

Same thing.  Nothing in dmesg or /var/log/messages.  I know this worked
not long ago....

-Eric

