Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f44.google.com ([209.85.219.44]:65229 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbaEWCOs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 22 May 2014 22:14:48 -0400
Received: by mail-oa0-f44.google.com with SMTP id o6so4946368oag.3
        for <linux-nfs@vger.kernel.org>; Thu, 22 May 2014 19:14:48 -0700 (PDT)
Message-ID: <537EAF05.2020900@gmail.com>
Date: Fri, 23 May 2014 10:14:29 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org, kinglongmee@gmail.com
Subject: Get "device is busy" when umounting  nfsv4 file
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using NFSv4 on Fedora 20 with latest kernel (3.15.0-rc6+), 
I can't umount the mountpoint after only an 'ls' operation.

[root@localhost ~]# cat /etc/exports
/nfstest        *(rw,no_root_squash,no_subtree_check,insecure)
[root@localhost ~]# mount -t nfs 127.0.0.1:/ /mnt/
[root@localhost ~]# ls /mnt/
nfstest
[root@localhost ~]# umount /mnt/
umount.nfs4: /mnt: device is busy
