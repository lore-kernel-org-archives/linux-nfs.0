From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: NFS performance degradation of local loopback FS.
Date: Tue, 1 Jul 2008 15:49:44 +0530
Message-ID: <OF75C86F21.1DE4E6F9-ON65257479.00382C87-65257479.0038BD28@in.ibm.com>
References: <20080630153541.GD29011@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: aglo@citi.umich.edu, Benny Halevy <bhalevy@panasas.com>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
	Dean Hildebrand <seattleplus@gmail.com>,
	Peter Staubach <staubach@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp01.in.ibm.com ([59.145.155.1]:47985 "EHLO
	e28esmtp01.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752791AbYGAKVE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Jul 2008 06:21:04 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m61AKehj026006
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 15:50:40 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m61AKJTf634914
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 15:50:19 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m61AKdXJ022589
	for <linux-nfs@vger.kernel.org>; Tue, 1 Jul 2008 15:50:39 +0530
In-Reply-To: <20080630153541.GD29011@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 06/30/2008 09:05:41 PM:

> On Mon, Jun 30, 2008 at 11:26:54AM -0400, Jeff Layton wrote:
> > Recently I spent some time with others here at Red Hat looking
> > at problems with nfs server performance. One thing we found was that
> > there are some problems with multiple nfsd's. It seems like the I/O
> > scheduling or something is fooled by the fact that sequential write
> > calls are often handled by different nfsd's. This can negatively
> > impact performance (I don't think we've tracked this down completely
> > yet, however).
>
> Yes, we've been trying to see how close to full network speed we can get
> over a 10 gig network and have run into situations where increasing the
> number of threads (without changing anything else) seems to decrease
> performance of a simple sequential write.
>
> And the hypothesis that the problem was randomized IO scheduling was the
> first thing that came to mind.  But I'm not sure what the easiest way
> would be to really prove that that was the problem.
>
> And then once we really are sure that's the problem, I'm not sure what
> to do about it.  I suppose it may depend partly on exactly where the
> reordering is happening.

For 1 process, this theory seems to work:
1 testing process: /local:            39.11 MB/s
        64 nfsd's:                    29.63 MB/s
        1 nfs'd:                      38.99 MB/s


However for 6 processes reading 6 different files:
6 parallel testing processes: /local: 70 MB/s
        1 nfs'd:                      36 MB/s (49% drop)
        2 nfs'd:                      37.7 MB/s (46% drop)
        4 nfs'd:                      38.6 MB/s (44.9% drop)
        4 nfsd's on different cpu's:  37.5 MB/s (46% drop)
        32 nfs'd:                     38.3 MB/s (45% drop)
        64 nfs'd:                     38.3 MB/s (45% drop)

Thanks,

- KK

