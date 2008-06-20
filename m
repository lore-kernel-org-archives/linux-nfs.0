From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Fri, 20 Jun 2008 14:51:11 +0530
Message-ID: <OF9EA6D38A.FDD1F48D-ON6525746E.002D25B8-6525746E.003360EB@in.ibm.com>
References: <485A569A.8060601@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp07.in.ibm.com ([59.145.155.7]:57449 "EHLO
	e28esmtp07.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752896AbYFTJWT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jun 2008 05:22:19 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5K9Lrnm003665
	for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2008 14:51:53 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5K9KwAP549008
	for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2008 14:50:58 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5K9Lr4o013793
	for <linux-nfs@vger.kernel.org>; Fri, 20 Jun 2008 14:51:53 +0530
In-Reply-To: <485A569A.8060601@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy <bhalevy@panasas.com> wrote on 06/19/2008 06:22:42 PM:

> > Well, you aren't exactly comparing apples to apples.  The NFS
> > client does close-to-open semantics, meaning that it writes
> > all modified data to the server on close.  The dd commands run
> > on the local file system do not.  You might trying using
> > something which does an fsync before closing so that you are
> > making a closer comparison.
>
> try dd conv=fsync ...

I ran a single 'dd' with this option on /local and later on /nfs (same
filesystem nfs mounted on the same system). The script is umounting and
mounting local and nfs partitions between each 'dd'. Following are the
file sizes for 20 and 60 second runs respectively:
      -rw-r--r-- 1 root root 1558056960 Jun 20 14:41 local.1
      -rw-r--r-- 1 root root  671834112 Jun 20 14:41 nfs.1     (56% drop)
                        &
      -rw-r--r-- 1 root root 3845812224 Jun 20 14:42 local.1
      -rw-r--r-- 1 root root 2420342784 Jun 20 14:43 nfs.1     (37% drop)

Since I am new to NFS, I am not sure if this much degradation is expected,
or whether I need to tune something. Is there some code I can look at or
hack into to find possible locations for the performance fall? At this time
I cannot even tell whether the *possible* bug is in server or client code.

Thanks,

- KK

