Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:64817 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751058AbdBJNNc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Feb 2017 08:13:32 -0500
MIME-Version: 1.0
Message-ID: <trinity-11fbb131-e4ab-44da-854c-17ed6bd9a0da-1486732014080@3capp-mailcom-bs04>
From: daggs <daggs@gmx.com>
To: linux-nfs@vger.kernel.org
Subject: poor nfsv4 preformence
Content-Type: text/plain; charset=UTF-8
Date: Fri, 10 Feb 2017 14:06:54 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Greetings,

I have an odroidc2 board running kernel 3.14 with the following exportfs settings:
/mnt/media 10.0.0.0/24(rw,no_subtree_check,nohide,insecure)

the board has a 1000Gbit Ethernet, both ethtool and netcat based test shows 125 MB/s.
I've tried to test the write speed of both nfsv4 and nfsv3 on the same file and I get the following results:
dagg@NCC-5001-D /tmp $ ll /mnt/storage/video/Movies/tdm-stgc.mkv
-rw-r--r-- 1 dagg users 4677381547 Apr 18  2013 /mnt/storage/video/Movies/tdm-stgc.mkv

nfs V3 testing:
dagg@NCC-5001-D /tmp $ time cp /mnt/storage/video/Movies/tdm-stgc.mkv /tmp/media/

real    13m38.090s
user    0m0.007s
sys     0m2.453s

nfs V4 testing:
dagg@NCC-5001-D /tmp $ time cp /mnt/storage/video/Movies/tdm-stgc.mkv /tmp/media/

real    16m32.828s
user    0m0.007s
sys     0m2.047s

why is that? is my exportfs bad? can it be a kernel bug?

Dagg.
