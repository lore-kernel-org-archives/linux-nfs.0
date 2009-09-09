From: Nick Piggin <npiggin@suse.de>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Wed, 9 Sep 2009 07:39:26 +0200
Message-ID: <20090909053926.GA20862@wotan.suse.de>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org> <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com> <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu> <1240592448.4946.35.camel@heimdal.trondhjem.org> <20090425051028.GC10088@wotan.suse.de> <20090908153007.GB2513@think> <20090909022102.GA28318@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Mason <chris.mason@oracle.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Miklos Szeredi <miklos@szeredi.hu>, holt@sgi.com,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55311 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbZIIFjY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2009 01:39:24 -0400
In-Reply-To: <20090909022102.GA28318@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Sep 08, 2009 at 10:21:02PM -0400, Christoph Hellwig wrote:
> On Tue, Sep 08, 2009 at 11:30:07AM -0400, Chris Mason wrote:
> > Sorry for digging up an old thread, but is there any reason we can't
> > just use page_mkwrite here?  I'd love to get rid of the btrfs code to
> > detect places that use set_page_dirty without a page_mkwrite.
> 
> It's not just btrfs, it's also a complete pain in the a** for XFS and
> probably every filesystems using ->page_mkwrite for dirty page tracking.

Well I guess I should really get out my put_user_pages patches and
propose doing page locking or something. One problem is just going
through and converting all callers... another problem is that
nobody seemed to care much last time but hopefully there is more
interest now.

