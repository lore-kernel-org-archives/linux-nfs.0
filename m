Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39552 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933120AbcAYVT2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2016 16:19:28 -0500
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: [LSF/MM TOPIC] Remote access to pmem on storage targets
Date: Mon, 25 Jan 2016 16:19:24 -0500
Message-Id: <06414D5A-0632-4C74-B76C-038093E8AED3@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux RDMA Mailing List <linux-rdma@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: lsf-pc@lists.linux-foundation.org
Mime-Version: 1.0 (Mac OS X Mail 8.2 \(2104\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'd like to propose a discussion of how to take advantage of
persistent memory in network-attached storage scenarios.

RDMA runs on high speed network fabrics and offloads data
transfer from host CPUs. Thus it is a good match to the
performance characteristics of persistent memory.

Today Linux supports iSER, SRP, and NFS/RDMA on RDMA
fabrics. What kind of changes are needed in the Linux I/O
stack (in particular, storage targets) and in these storage
protocols to get the most benefit from ultra-low latency
storage?

There have been recent proposals about how storage protocols
and implementations might need to change (eg. Tom Talpey's
SNIA proposals for changing to a push data transfer model,
Sagi's proposal to utilize DAX under the NFS/RDMA server,
and my proposal for a new pNFS layout to drive RDMA data
transfer directly).

The outcome of the discussion would be to understand what
people are working on now and what is the desired
architectural approach in order to determine where storage
developers should be focused.

This could be either a BoF or a session during the main
tracks. There is sure to be a narrow segment of each
track's attendees that would have interest in this topic.

--
Chuck Lever




