From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 0/11] nfsd: Summary of "Improve NFS server performance"
Date: Sat, 18 Apr 2009 01:00:07 +0530
Message-ID: <OFE69B4461.C8B6EE1C-ON6525759B.006A36D1-6525759B.006B20D2@in.ibm.com>
References: <20090325133607.16437.33288.sendpatchset@localhost.localdomain> <20090417184647.GA19990@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: jlayton@redhat.com, Krishna Kumar <krikku@gmail.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e28smtp05.in.ibm.com ([59.145.155.5]:48069 "EHLO
	e28smtp05.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbZDQTbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Apr 2009 15:31:11 -0400
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3HJV96n031259
	for <linux-nfs@vger.kernel.org>; Sat, 18 Apr 2009 01:01:09 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3HJVKqx3862668
	for <linux-nfs@vger.kernel.org>; Sat, 18 Apr 2009 01:01:20 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3HJV8Mf029607
	for <linux-nfs@vger.kernel.org>; Sat, 18 Apr 2009 05:31:08 +1000
In-Reply-To: <20090417184647.GA19990@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"J. Bruce Fields" <bfields@fieldses.org> wrote on 04/18/2009 12:16:47 AM:

> Re: [PATCH 0/11] nfsd: Summary of "Improve NFS server performance"
>
> On Wed, Mar 25, 2009 at 07:06:07PM +0530, Krishna Kumar wrote:
> > From: Krishna Kumar <krkumar2@in.ibm.com>
> >
> >          Patch summary:
> >          --------------
> > Change the caching from ino/dev to a file handle model. Advantages:
> >
> > 1. Since file handles are unique, this patch removes all dependencies
on the
> >    kernel readahead parameters and it's implementation; and instead
caches> >    files based on file handles.
> > 2. Allows the server to not have to open/close a file multiple times
when the
> >    client reads it, and results in faster lookup times.
> > 3. Readahead is automatically taken care of since the file is not
closed while
> >    it is getting read (quickly) by the client.
> > 4. Another optimization is to avoid getting the cache lock twice for
each read
> >    operation (after the first time it is taken to update the cache).
> > 5. (ra_size, ra_depth retain the "ra" prefix for now, since I have not
checked
> >    whether changing that will break any user programs)
>
> You're referring here to the "ra" line in /proc/net/rpc/nfsd?

Yes - at that time I was thinking of any consumer of this file. From your
comment,
I see that it is not an issue now, thanks for pointing it out.

Thanks,

- KK

