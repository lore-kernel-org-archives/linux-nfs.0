From: Ray Van Dolson <rvandolson-v48TKWNzwFw@public.gmane.org>
Subject: Proper way to request async from NFS server?
Date: Mon, 4 Jan 2010 23:56:10 -0800
Message-ID: <20100105075610.GA435@esri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from esrismtp2.esri.com ([198.102.62.103]:59444 "EHLO esri3.esri.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754400Ab0AEIBz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Jan 2010 03:01:55 -0500
Received: from leoray.esri.com (leoray.esri.com [10.27.102.12])
	by esri3.esri.com (8.11.7p3+Sun/8.11.7) with ESMTP id o057uA629233
	for <linux-nfs@vger.kernel.org>; Mon, 4 Jan 2010 23:56:10 -0800 (PST)
Received: from leoray.esri.com (leoray.esri.com [127.0.0.1])
	by leoray.esri.com (8.14.3/8.14.3) with ESMTP id o057uAY7000542
	for <linux-nfs@vger.kernel.org>; Mon, 4 Jan 2010 23:56:10 -0800
Received: (from ray5147@localhost)
	by leoray.esri.com (8.14.3/8.14.3/Submit) id o057uAQl000540
	for linux-nfs@vger.kernel.org; Mon, 4 Jan 2010 23:56:10 -0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RHEL 5.4 NFSv3 client accessing a Solaris 10 NFS export.

Solaris 10 does not offer a way to specify whether a given share is
async or sync as the Linux NFS server does.  As far as I understand it,
its NFS server will honor whatever the connecting NFS client requests.

I'm mounting a Solaris NFS share with -o async (or using async in the
options field in fstab).  Though this completes without complaint, I
don't see "async" listed in the mount options under /proc/mounts and
when I do a snoop on the Solaris side, all the write requests are FSYNC
instead of ASYNC.

Am I doing something wrong?  What's the correct way to get the Linux
NFS client to request asynchronous operation?

This is with nfs-utils 1.0.9 and of course, the RHEL5 kernel
2.6.18-164.6.1.el5.

Thanks,
Ray
