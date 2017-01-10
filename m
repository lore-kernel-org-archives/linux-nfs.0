Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from forward8j.cmail.yandex.net ([5.255.227.109]:34588 "EHLO
        forward8j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750959AbdAJWpV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jan 2017 17:45:21 -0500
Received: from mxback7m.mail.yandex.net (mxback7m.mail.yandex.net [37.140.138.67])
        by forward8j.cmail.yandex.net (Yandex) with ESMTP id 30F9522113
        for <linux-nfs@vger.kernel.org>; Wed, 11 Jan 2017 01:37:51 +0300 (MSK)
From: =?utf-8?B?0JfQsNCx0L7Qu9C+0YLQvdGL0Lkg0JDQvdC00YDQtdC5?=
        <zapparello@yandex.ru>
To: linux-nfs@vger.kernel.org
Subject: NFSD high CPU usage
MIME-Version: 1.0
Message-Id: <3185301484087870@web25m.yandex.ru>
Date: Wed, 11 Jan 2017 01:37:50 +0300
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

I'm trying to narrow down a problem I've got, and I'm asking for help from knowledgeable people.
I'm sorry if this is the wrong place to ask, please direct me to the right place if I'm wrong.

I have a simple NAS which is built around a dual-core 300MHz ARM with linux 2.6.31, and has a gigabit Ethernet controller.
It can share a SATA hard drive (I have a 2Tb drive installed) over the network using NFSv3 and SMB.
I did a comparison of the raw download speed from NAS hard disk over the GbE to my PC using NFSv3 and SAMBA.
Basically, I just copy a large enough file (several gigabytes) from the mounted NAS share to /dev/null.

With SAMBA I get about 53Mbyte/second (over 400 Megabits) and NAS CPU usage of a single CPU ARM core is about 26%, the other core is idle.

With NFS I get about 17MByte/second when using one NFSD thread and about 28MByte/second when using two and more NFSD threads. In this case the limiting factor is CPU as I can see a 100% CPU load on one or both cores. I tried using TCP or UDP, played with rsize/wsize but this does not change the results much.

I have the kernel sources from the manufacturer, so my idea is to fix the problem and update the kernel on NAS.

So, my questions are:

1. Are there any changes in kernel NFSD since kernel 2.6.31 that could influence CPU usage? I could try to backport the patches.

2. What could cause this high CPU usage on just sequential reads from a file on a NFS drive? In fs/nfsd/vfs.c I see that the nfsd_read() function will open the file, read some bytes, and close it - on every read operation? Is this the cause of high CPU load? 
Also, I can see that NFSv4 does not do the open/close on every read - is NFSv4 CPU usage lower when issuing many sequential reads?

-- 
Andrew
