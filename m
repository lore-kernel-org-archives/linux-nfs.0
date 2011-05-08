Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34042 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949Ab1EHVUG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 8 May 2011 17:20:06 -0400
Date: Sun, 8 May 2011 17:20:03 -0400
To: Andrew Klaassen <clawsoon@yahoo.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Fwd: Prioritizing readdirplus/getattr/lookup
Message-ID: <20110508212003.GA29337@fieldses.org>
References: <4104737B-ECEA-46F7-BD26-39241DB8EBAF@oracle.com>
 <521591.18062.qm@web65408.mail.ac4.yahoo.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <521591.18062.qm@web65408.mail.ac4.yahoo.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Apr 05, 2011 at 09:32:38AM -0700, Andrew Klaassen wrote:
> I've done some more benchmarking, and in my case writes appear to *not* be the culprit.
> 
> Having the HPC farm only reading files (with noatime set everywhere, of course) actually makes "ls -l" over NFS slightly ~slower~.

Do you know which part of 'ls -l' is taking longer?  The readdir, or the
stats?  (Would an strace determine it?)  Probably the latter, I guess.
(Apologies if you already said.)

> Having the HPC farm only reading files that all fit in the server's cache makes "ls -l" over NFS yet slower.  (I watched iostat while this was running to make sure that nothing was being written to or read from disk.)
> 
> So I've eliminated the disk as a bottleneck, and (as per my earlier emails) I've eliminated the filesystem and VM system.
> 
> It really does look at this point like nfsd is the choke point.

So I suppose the replies are likely waiting to be sent back over the tcp
connection to the client, and waiting behind big read replies?

As a check I wonder if there's any cheesy way we could prioritize
threads waiting to send back getattr requests over threads waiting to
send back reads.

Such threads are waiting on the xpt_mutex.  Is there some mutex or
semaphore variant that gives us control over the order things are woken
up in, or would we need our own?

--b.
