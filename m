Return-Path: linux-nfs-owner@vger.kernel.org
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:47750 "EHLO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966457Ab3DQOgd convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Apr 2013 10:36:33 -0400
From: Yan Burman <yanb@mellanox.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Tom Tucker <tom@opengridcomputing.com>
CC: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: NFS over RDMA benchmark
Date: Wed, 17 Apr 2013 14:36:23 +0000
Message-ID: <0EE9A1CDC8D6434DB00095CD7DB873462CF96C65@MTLDAG01.mtl.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

I've been trying to do some benchmarks for NFS over RDMA and I seem to only get about half of the bandwidth that the HW can give me.
My setup consists of 2 servers each with 16 cores, 32Gb of memory, and Mellanox ConnectX3 QDR card over PCI-e gen3.
These servers are connected to a QDR IB switch. The backing storage on the server is tmpfs mounted with noatime.
I am running kernel 3.5.7.

When running ib_send_bw, I get 4.3-4.5 GB/sec for block sizes 4-512K.
When I run fio over rdma mounted nfs, I get 260-2200MB/sec for the same block sizes (4-512K). running over IPoIB-CM, I get 200-980MB/sec.
I got to these results after the following optimizations:
1. Setting IRQ affinity to the CPUs that are part of the NUMA node the card is on
2. Increasing /proc/sys/sunrpc/svc_rdma/max_outbound_read_requests and /proc/sys/sunrpc/svc_rdma/max_requests to 256 on server
3. Increasing RPCNFSDCOUNT to 32 on server
4. FIO arguments: --rw=randread --bs=4k --numjobs=2 --iodepth=128 --ioengine=libaio --size=100000k --prioclass=1 --prio=0 --cpumask=255 --loops=25 --direct=1 --invalidate=1 --fsync_on_close=1 --randrepeat=1 --norandommap --group_reporting --exitall --buffered=0

Please advise what can be done to improve bandwidth.

BTW, I also tried latest net-next tree (3.9-rc5), and when both server and client are 3.9, the client gets IO error when trying to access a file on nfs mount.
When server is 3.9 and client is 3.5.7, I managed to get through all randread tests with fio, but when I got to randwrite, the server crashes.

Thanks in advance
Yan

