From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Thu, 26 Jun 2008 12:49:03 +0530
Message-ID: <OFA5778CCB.84AF3576-ON65257474.0027EF21-65257474.00283248@in.ibm.com>
References: <485F99C8.2000800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Peter Staubach <staubach@redhat.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:46057 "EHLO
	e28esmtp02.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755283AbYFZHTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2008 03:19:42 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5Q7JIK7017363
	for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2008 12:49:18 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5Q7IEKF786580
	for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2008 12:48:14 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5Q7JIdc024147
	for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2008 12:49:18 +0530
In-Reply-To: <485F99C8.2000800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Halevy <bhalevy@panasas.com> wrote on 06/23/2008 06:10:40 PM:

> Apparently the file is cached.  You needed to restart nfs
> and remount the file system to make sure it isn't before reading it.
> Or, you can create a file larger than your host's cache size so
> when you write (or read) it sequentially, its tail evicts its head
> out of the cache.  This is a less reliable method, yet creating a
> file about 25% larger than the host's memory size should work for you.

I did a umount of all filesystems and restart NFS before testing. Here
is the result:

Local:
      Read:  69.5 MB/s
      Write: 70.0 MB/s
NFS of same FS mounted loopback on same system:
      Read:  29.5 MB/s  (57% drop)
      Write: 27.5 MB/s  (60% drop)

The drops seems exceedingly high. How can I figure out the source of the
problem? Even if it is as general as to be able to state: "Problem is in
the NFS client code" or "Problem is in the NFS server code", or "Problem
can be mitigated by tuning" :-)

Thanks,

- KK

