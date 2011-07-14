Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merit-proxy02.merit.edu ([207.75.116.194]:59851 "EHLO
	merit-proxy02.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113Ab1GNRJr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jul 2011 13:09:47 -0400
Date: Thu, 14 Jul 2011 13:09:24 -0400
From: Jim Rees <rees@umich.edu>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: block layout patches
Message-ID: <20110714170924.GC2607@merit.edu>
References: <20110714165004.GA2607@merit.edu>
 <20110714165348.GA13287@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110714165348.GA13287@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Christoph Hellwig wrote:

  Err, what about actually posting them for review first?  The only thing
  so far has been all that squashme mess.

Sorry for the missing context.  About a month ago I sent out an 88 patch set
for pNFS Bakeathon.  That was a squashme mess.  Later I sent a 35 patch set,
and got back a number of comments.  That's had a number of re-writes
resulting in the current patch set, which is 28 patches.

While you're certainly welcome to review what's there now, it's mostly meant
for Benny to pull into his tree to resolve any issues merging with other
pNFS patches that haven't gone upstream yet.

I have a couple more changes to make before sending upstream:

1. replace the upcall mechanism
2. rebase on Trond's IO changes that are now in his nfs-for-next branch

After that I will be sending the entire patch set to the list and soliciting
comments from reviewers.  I would very much appreciate it if you could take
the time to look them over when I do.
