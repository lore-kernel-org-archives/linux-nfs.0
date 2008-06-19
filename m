From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Thu, 19 Jun 2008 15:28:06 +0530
Message-ID: <OF279AC296.24F27581-ON6525746D.00367A24-6525746D.0036C258@in.ibm.com>
References: <OF31144E99.0651F8EE-ON6525746D.001E6B1B-6525746D.002534E9@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:35764 "EHLO
	e28esmtp05.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757423AbYFSJ7S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2008 05:59:18 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5J9wkGE005003
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 15:28:46 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5J9wSFO1196168
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 15:28:28 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5J9wj0a014265
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 15:28:45 +0530
Received: from d23ml172.in.ibm.com (d23ml172.in.ibm.com [9.124.105.37])
	by d28av04.in.ibm.com (8.13.1/8.12.11) with ESMTP id m5J9wjYb014262
	for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 15:28:45 +0530
In-Reply-To: <OF31144E99.0651F8EE-ON6525746D.001E6B1B-6525746D.002534E9@in.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>       200 processes:

By "200 processes", I meant 200 dd's, each reading from /dev/zero and
writing to a file on the filesystem. The script "nfs" was run twice, first
with
a local filesystem and the second time with the same filesystem NFS
mounted.

Thanks,

- KK

linux-nfs-owner@vger.kernel.org wrote on 06/19/2008 12:16:23 PM:

>
> Hi,
>
> I am running 2.6.25 kernel on a [4 way, 3.2 x86_64, 4GB] system. The test
> is doing I/O on a local ext3 filesystem, and measuring the bandwidth, and
> then NFS mounting the filesystem loopback on the same system. I have
> configured 64 nfsd's to run. The test script is attached at the bottom.
>
> My configuration is:
>       /dev/some-local-disk  :            /local
>       NFS mount /local       :            /nfs
>
> The result is:
>       200 processes:
>             /local: 108000 KB/s
>             /nfs:     66000 KB/s: Drop of 40%
>
>       300 processes (KB/s):
>             /local: 112000 KB/s
>             /nfs:    57000 KB/s: Drop of 50%
>
> I am not using any tuning, though I have tested with both
> sunrpc.tcp_slot_table_entries=16 & 128
>
> Is this big a drop expected for a loopback NFS mount? Any
> feedback/suggestions are very
> appreciated.
>
> Thanks,
>
> - KK
>
> (See attached file: nfs)[attachment "nfs" deleted by Krishna
Kumar2/India/IBM]

