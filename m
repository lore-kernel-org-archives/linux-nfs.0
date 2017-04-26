Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:51731 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S964820AbdDZSfT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 14:35:19 -0400
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <glN-linux-nfs@m.gmane.org>)
        id 1d3RmL-0006hp-Jg
        for linux-nfs@vger.kernel.org; Wed, 26 Apr 2017 20:35:05 +0200
To: linux-nfs@vger.kernel.org
From: scar <scar@drigon.com>
Subject: rdma connection close/reopen every 5 mins
Date: Wed, 26 Apr 2017 10:23:40 -0700
Message-ID: <odql2m$vup$1@blaine.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, I have setup NFS/RDMA on our infiniband network.  The OS is 
CentOS 6.8 with kernel 2.6.32-696.1.1.el6.x86_64 and I am using 
rdma/nfs-rdma packages from the OS version 6.9_4.1.  The connection is 
successful:

10.10.11.249:/newwing on /newwing type nfs 
(rw,rdma,port=20049,addr=10.10.11.249)

except in /var/log/messages I am always seeing this exactly every 5 minutes:
  kernel: rpcrdma: connection to 10.10.11.249:20049 closed (-103)
  kernel: rpcrdma: connection to 10.10.11.249:20049 on mlx4_0, memreg 6 
slots 32 ird 16

I suppose it is from some service or cron job.... But I wonder how I 
could keep the connection open so this isn't happening every 5 minutes?

Thanks

