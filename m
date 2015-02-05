Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51099 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753298AbbBEOWf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 09:22:35 -0500
Date: Thu, 5 Feb 2015 06:22:35 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, fstests@vger.kernel.org,
        linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH] fsx: check for filesystem support of
 FALLOCATE_FL_KEEP_SIZE
Message-ID: <20150205142235.GA24816@infradead.org>
References: <1422997783-22484-1-git-send-email-Anna.Schumaker@Netapp.com>
 <54D37B33.9090501@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54D37B33.9090501@plexistor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 05, 2015 at 04:16:19PM +0200, Boaz Harrosh wrote:
> On 02/03/2015 11:09 PM, Anna Schumaker wrote:
> > The NFS implementation of fallocate() does not support passing the
> > KEEP_SIZE flag by itself, causing tests to randomly fail.
> > 
> 
> This I do not understand please explain. If all the other FSs just ignore
> a trivial case, then why should NFS not ignore it the same as all
> other filesystems.
> 
> Why NFS is allowed to be special. (And apparently break user code xfs
> being an example of one)

fsx is a test tool.  We've never guaranteed that a filesystem needs to
support all or a special subset of fallocate options.

The NFSv4.2 protocol doesn't support preallocations beyond the file
size, which is something I decided would be to horrible to refit into
the NFS file abstraction when rewriting the preallocation / reservation
section of the spec.
