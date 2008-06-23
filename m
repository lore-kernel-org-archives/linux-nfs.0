From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 23 Jun 2008 13:41:06 +0530
Message-ID: <OF5D1728DA.B4C6E2E0-ON65257471.0027ACA3-65257471.002CF647@in.ibm.com>
References: <485E0ED5.7030501@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Benny Halevy <bhalevy.lists@gmail.com>, linux-nfs@vger.kernel.org,
	Peter Staubach <staubach@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:56797 "EHLO
	e28esmtp07.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753189AbYFWIME (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2008 04:12:04 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5N8BWUI012642
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2008 13:41:32 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5N8BDpc1355940
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2008 13:41:13 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5N8BVTW027567
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2008 13:41:32 +0530
In-Reply-To: <485E0ED5.7030501@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Benny,

> According to dd's man page, the f{,date}sync options tell it to
> "physically write output file data before finishing"
> If you kill it before that you end up with dirty data in the cache.
> What exactly are you trying to measure, what is the expected application
> workload?

I changed my test to do what you were doing instead of killing
dd's, etc. The end application is DB2 and it is using multiple
processes and I wanted to simulate that with micro-benchmarks.
The only reliable way to benchmark bandwidth for multiple
processes is to kill the tests after running them for some time
instead of letting them run till conclusion.

> ext3 mount options: noatime
> nfs mount options: rsize=65536,wsize=65536
> dd options: bs=64k count=10k conv=fsync
>
> (write results average of 3 runs)
> write local disk:     47.6 MB/s
> write loopback nfsv3: 30.2 MB/s
> write remote nfsv3:   29.0 MB/s
> write loopback nfsv4: 37.5 MB/s
> write remote nfsv4:   29.1 MB/s
>
> read local disk:      50.8 MB/s
> read loopback nfsv3:  27.2 MB/s
> read remote nfsv3:    21.8 MB/s
> read loopback nfsv4:  25.4 MB/s
> read remote nfsv4:    21.4 MB/s

I used the exact same options you are using, and here is the results
averaged across 3 runs:

Write local disk      58.5 MB/s
Write loopback nfsv3: 29.42 MB/s (50% drop)

Reading (file created from /dev/urandom, somehow I am getting in GB/sec
            while your results were comparable to write's):
      Read local disk:      2.77 GB/s
      Read loopback nfsv3:  2.86 GB/s (higher for some reason)

Thanks,

- KK

