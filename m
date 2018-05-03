Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:52000 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbeECUkT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 May 2018 16:40:19 -0400
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <glN-linux-nfs@m.gmane.org>)
        id 1fEKzN-0002Xg-Uu
        for linux-nfs@vger.kernel.org; Thu, 03 May 2018 22:38:05 +0200
To: linux-nfs@vger.kernel.org
From: scar <scar@drigon.com>
Subject: RDMA connection lost and not re-opened
Date: Thu, 3 May 2018 13:40:09 -0700
Message-ID: <pcfrv6$940$1@blaine.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We are using NFSoRDMA on our cluster, which is using CentOS 6.9 with 
kernel 2.6.32-696.1.1.el6.x86_64.  2/10 of the clients had to be 
rebooted recently.  It appears due to NFS connection closed but not 
reopened.  For example, we will commonly see these messages:

May  2 14:46:08 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  2 15:42:39 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  2 15:42:44 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  2 16:04:02 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  2 16:04:02 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  2 18:46:00 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  2 19:16:09 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  2 19:28:49 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  2 21:14:42 n006 kernel: rpcrdma: connection to 10.10.11.10:20049 
closed (-103)
May  3 11:51:13 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  3 11:56:13 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  3 13:14:34 n006 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16


I asked about these messages previously and they are just normal 
operations.  You can see the connection is usually reopened immediately 
if the resource is still required, but the message at 21:14:42 was not 
accompanied with a re-opening message, and this is about the time the 
client hung and became unresponsive.  I noticed similar messages on the 
other server that had to be rebooted:

May  2 15:46:52 n001 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  2 16:08:39 n001 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  2 19:14:23 n001 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  2 21:14:38 n001 kernel: rpcrdma: connection to 10.10.11.10:20049 
closed (-103)
May  3 11:54:58 n001 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  3 11:59:59 n001 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)
May  3 12:50:57 n001 kernel: rpcrdma: connection to 10.10.11.249:2050 on 
mlx4_0, memreg 5 slots 32 ird 16
May  3 12:55:58 n001 kernel: rpcrdma: connection to 10.10.11.249:2050 
closed (-103)


You can see on each machine that the connection to 10.10.11.249:2050 was 
re-opened when i tried to login today on May 3 but the connection to 
10.10.11.10:20049 was not re-opened.  Meanwhile our other clients still 
have the connection to 10.10.11.10:20049 and the server at 10.10.11.10 
is working fine.

Any idea why this happened and how it could possibly be resolved without 
having to reboot the server and losing work?

Thanks

