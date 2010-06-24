From: yo mama <mamamia69@gmail.com>
Subject: Performance issues with pNFS
Date: Thu, 24 Jun 2010 20:59:05 +0530
Message-ID: <AANLkTilQPbs4yYGOCmj5Olo_YPKc0vrX8zChPRxv8NWL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:33171 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755270Ab0FXPe0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jun 2010 11:34:26 -0400
Received: by ewy20 with SMTP id 20so388129ewy.19
        for <linux-nfs@vger.kernel.org>; Thu, 24 Jun 2010 08:34:23 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

ran a test to check trhoughput of , I am seeing drop in
 performance contrary to what is expected with multiple DS are added. Any
 thoughts on why there is no scaling of read performace is appreciated.

 ./iozone -I -i 0 -i 2 -s 512m -r 4 -t 1

 -I disable FS caching and run Direct I/O

 -i 0 sequential write

 -i 2 random read and write

 -s 512m file size twice the size of RAM (256MB)

 -r record size 4KB

 -t 1 throughout mode and one thread

 With one DS server enabled in spnfd.conf

 One DS server Random read


     Children see throughput for 1 random readers    =    3355.27 KB/sec
         Parent sees throughput for 1 random readers     =    3355.21 KB/sec
         Min throughput per process                      =    3355.27 KB/sec
         Max throughput per process                      =    3355.27 KB/sec
         Avg throughput per process                      =    3355.27 KB/sec
         Min xfer                                        =  524288.00 KB

 two DS servers Random read

 Children see throughput for 1 random readers    =    3098.43 KB/sec
         Parent sees throughput for 1 random readers     =    3098.36 KB/sec
         Min throughput per process                      =    3098.43 KB/sec
         Max throughput per process                      =    3098.43 KB/sec
         Avg throughput per process                      =    3098.43 KB/sec
         Min xfer                                        =  524288.00 KB
