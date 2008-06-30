From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Mon, 30 Jun 2008 15:40:30 +0530
Message-ID: <OF20F6A497.A6F52D0F-ON65257478.00377AB6-65257478.0037E4AE@in.ibm.com>
References: <48652C24.6030409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>
To: Dean Hildebrand <seattleplus@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:44812 "EHLO
	e28esmtp01.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755095AbYF3KLr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 06:11:47 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5UABJLR031142
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 15:41:19 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5UAAw8j1179822
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 15:40:58 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5UABIQS006269
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2008 15:41:18 +0530
In-Reply-To: <48652C24.6030409@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dean Hildebrand <seattleplus@gmail.com> wrote on 06/27/2008 11:36:28 PM:

> One option might be to try using O_DIRECT if you are worried about
> memory (although I would read/write in at least 1 MB at a time).  I
> would expect this to help at least a bit especially on reads.
>
> Also, check all the standard nfs tuning stuff, #nfsds, #rpc slots.
> Since with a loopback you effectively have no latency, you would want to
> ensure that neither the #nfsds or #rpc slots is a bottleneck (if either
> one is too low, you will have a problem).  One way to reduce the # of
> requests and therefore require fewer nfsds/rpc_slots is to 'cat
> /proc/mounts' to see your wsize/rsize.  Ensure your wsize/rsize is a
> decent size (~ 1MB).

Number of nfsd: 64, and
      sunrpc.transports = sunrpc.udp_slot_table_entries = 128
      sunrpc.tcp_slot_table_entries = 128

I am using:

      mount -o
rw,bg,hard,nointr,proto=tcp,vers=3,rsize=65536,wsize=65536,timeo=600,noatime
 localhost:/local /nfs

I have also tried with 1MB for both rsize/wsize and it didn't change the BW
(other than
mini variations).

thanks,

- KK

