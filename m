From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [Bugme-new] [Bug 11448] New: NFS client has inconsistent write
	flushing to non-linux serversa
Date: Fri, 29 Aug 2008 13:08:38 -0400
Message-ID: <20080829170838.GA7099@fieldses.org>
References: <bug-11448-10286@http.bugzilla.kernel.org/> <20080828132753.08bfe05f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org,
	doug-rDJHdQPhaF8@public.gmane.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:38605 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752317AbYH2RIl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Aug 2008 13:08:41 -0400
In-Reply-To: <20080828132753.08bfe05f.akpm@linux-foundation.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 28, 2008 at 01:27:53PM -0700, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).
> 
> On Thu, 28 Aug 2008 11:41:08 -0700 (PDT)
> bugme-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org wrote:
> > NFS client writes to Sun Solaris 10 U4 server. 
> > at some point in time, there is an empty portion of the output file from the
> > writer containing missing data (shows as NULL bytes from another NFS client
> > issuing a tail -f on the file being written). 
> > confirmed that the file as exists on the NFS server is sparse, missing bytes
> > (not necessarily multiple of 512 or 1024, one sample is a gap of 3818 bytes,
> > another is 1895 bytes, another is 423 bytes)

Seems like something that could happen if for example two write rpc's
got reordered on the network.  That's not necessarily a bug--the nfs
client isn't required to wait for confirmation of every previous write
before sending the next one.

However if the client isn't flushing dirty data to the server before
returning from close, then that's a violation of NFS's close-to-open
semantics:...

> > 
> > if you do a read of the entire file from the NFS client doing the writing, it
> > causes the non-flushed writes to be instantly flushed to the server followed by
> > a NFS3 commit operation. The data then can be seen on all other NFS clients.
> > 
> > If you do an open of the file alone, no flush
> > if you do an open and a close, no flush

... so this "close, no flush" could be a bug (depending on who is doing
that close when--I don't completely understand the described situation).

--b.
