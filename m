From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/6] VFS: Ensure that writeback_single_inode() commits
	unstable writes
Date: Fri, 8 Jan 2010 04:25:42 -0500
Message-ID: <20100108092542.GA27480@infradead.org>
References: <20100106205110.22547.85345.stgit@localhost.localdomain> <20100106205110.22547.17971.stgit@localhost.localdomain> <20100107021849.GC9475@localhost> <1262839082.2185.15.camel@localhost> <20100107145635.GB20300@localhost> <1262877022.3309.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wu Fengguang <fengguang.wu@intel.com>,
	Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>,
	Steve Rago <sar-a+KepyhlMvJWk0Htik3J/w@public.gmane.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"jens.axboe" <jens.axboe@oracle.com>,
	Peter Staubach <staubach@redhat.com>,
	Arjan van de Ven <arjan@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56674 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920Ab0AHJZ5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jan 2010 04:25:57 -0500
In-Reply-To: <1262877022.3309.11.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 07, 2010 at 10:10:22AM -0500, Trond Myklebust wrote:
> As I said previously, the write_inode() call is done _before_ you sync
> the dirty pages to the server, whereas commit_unstable_pages() wants to
> be done _after_ syncing. So the two are not the same, and we cannot
> replace commit_unstable_pages() with write_inode().

But that's more an accident of how this code was written.  The right
order nees to be to write the pages first, then call write_inode.  Most
modern filesystems have to work around this in their write_inode method
by waiting for the pages themselves.  I already fixed the same ordering
issue in fsync, and the writeback code is next on the agenda.

