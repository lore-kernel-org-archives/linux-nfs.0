Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:44479 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab1BOAVH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Feb 2011 19:21:07 -0500
Received: by iyj8 with SMTP id 8so5391023iyj.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Feb 2011 16:21:07 -0800 (PST)
Date: Mon, 14 Feb 2011 16:21:07 -0800
Message-ID: <AANLkTimyXBKeFJ2_mmHvCsC9EBEO0mb_ontXKaOxwtav@mail.gmail.com>
Subject: Oops.... cannot mount secure nfs exports (kerberized nfs / rpc.gssd crashes)
From: Di Pe <dipeit@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Could someone have a look at this

https://bugzilla.novell.com/show_bug.cgi?id=668880

Thanks
-------------

ox6:~ # rpm -q nfs-client
nfs-client-1.2.3-7.1.x86_64

ox6:~ # uname -a
Linux ox6 2.6.37-20-desktop #1 SMP PREEMPT 2011-01-22 00:41:44 +0100
x86_64 x86_64 x86_64 GNU/Linux

ox6:~ # mount -t nfs4 -o sec=krb5 home:/vol/home_ph1 /mnt/home/home_ph1

Message from syslogd@ox6 at Feb 14 16:16:54 ...
 kernel:[ 6376.964544] Oops: 0000 [#1] PREEMPT SMP

Message from syslogd@ox6 at Feb 14 16:16:54 ...
 kernel:[ 6376.964547] last sysfs file: /sys/module/auth_rpcgss/initstate

Message from syslogd@ox6 at Feb 14 16:16:54 ...
 kernel:[ 6376.964672] Stack:

Message from syslogd@ox6 at Feb 14 16:16:54 ...
 kernel:[ 6376.964694] Call Trace:

Message from syslogd@ox6 at Feb 14 16:16:54 ...
 kernel:[ 6376.965010] Code: e8 2b fd ff ff 48 8b 43 58 2a 43 50 88 43
4e eb e9 90 90 90 90 90 90 90 90 90 90 90 90 90 90 90 48 89 f8 89 d1
c1 e9 03 83 e2 07 <f3> 48 a5 89 d1 f3 a4 c3 20 48 83 ea 20 4c 8b 06 4c
8b 4e 08 4c

Message from syslogd@ox6 at Feb 14 16:16:54 ...
 kernel:[ 6376.965010] CR2: ffff88002022ff28
