Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:26940 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936795AbdDZUbT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Apr 2017 16:31:19 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: rdma connection close/reopen every 5 mins
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <odql2m$vup$1@blaine.gmane.org>
Date: Wed, 26 Apr 2017 13:32:35 -0700
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <97258237-282D-4A72-9AEE-BC1B82DF8E1C@oracle.com>
References: <odql2m$vup$1@blaine.gmane.org>
To: scar <scar@drigon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 26, 2017, at 10:23 AM, scar <scar@drigon.com> wrote:
> 
> Hello, I have setup NFS/RDMA on our infiniband network.  The OS is CentOS 6.8 with kernel 2.6.32-696.1.1.el6.x86_64 and I am using rdma/nfs-rdma packages from the OS version 6.9_4.1.  The connection is successful:
> 
> 10.10.11.249:/newwing on /newwing type nfs (rw,rdma,port=20049,addr=10.10.11.249)
> 
> except in /var/log/messages I am always seeing this exactly every 5 minutes:
> kernel: rpcrdma: connection to 10.10.11.249:20049 closed (-103)
> kernel: rpcrdma: connection to 10.10.11.249:20049 on mlx4_0, memreg 6 slots 32 ird 16

> I suppose it is from some service or cron job.... But I wonder how I could keep the connection open so this isn't happening every 5 minutes?

If it's every 5 minutes, that's probably the RPC idle timeout
that is closing the connection.

So this should be entirely harmless.


--
Chuck Lever



