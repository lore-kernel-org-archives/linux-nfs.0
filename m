From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Tue, 1 Jul 2008 10:37:12 +0530
Message-ID: <OF003147DE.D55CFB53-ON65257479.001B8D23-65257479.001C201E@in.ibm.com>
References: <20080630112654.012ce3e4@barsoom.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org, Dean Hildebrand <seattleplus@gmail.com>,
	Peter Staubach <staubach@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:60188 "EHLO
	e28esmtp06.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750945AbYGAFIZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2008 01:08:25 -0400
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m61584w5006237
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 10:38:04 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m6156pFk954564
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 10:36:51 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m61582lB031078
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 10:38:03 +0530
In-Reply-To: <20080630112654.012ce3e4-xSBYVWDuneFaJnirhKH9O4GKTjYczspe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jeff Layton <jlayton@redhat.com> wrote on 06/30/2008 08:56:54 PM:

> Recently I spent some time with others here at Red Hat looking
> at problems with nfs server performance. One thing we found was that
> there are some problems with multiple nfsd's. It seems like the I/O
> scheduling or something is fooled by the fact that sequential write
> calls are often handled by different nfsd's. This can negatively
> impact performance (I don't think we've tracked this down completely
> yet, however).
>
> Since you're just doing some single-threaded testing on the client
> side, it might be interesting to try running a single nfsd and testing
> performance with that. It might provide an interesting data point.

Works perfectly now!

With 64 nfsd's:
[root@localhost nfs]# ./perf
      ********** Testing on /nfs *************
      Read Time: 50.6236      BW:29.63 MB/s
      ********** Testing on /local *************
      Read Time: 38.3506      BW:39.11 MB/s

With 1 nfs'd:
[root@localhost nfs]# ./perf
      ********** Testing on /nfs *************
      Read Time: 38.4760      BW:38.99 MB/s
      ********** Testing on /local *************
      Read Time: 38.4874      BW:38.97 MB/s

I will try your other suggestions too.

I have to see what happens if I increase my processes. The real test is
DB2 using 300 connections. I will update when I run some more tests. But
thanks to everyone's help so far.

Regards,

- KK

