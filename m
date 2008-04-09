From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [GIT] Please pull NFS client fixes against linux-2.6.25-rc8
Date: Wed, 09 Apr 2008 09:37:31 -0400
Message-ID: <1207748251.8303.31.camel@heimdal.trondhjem.org>
References: <1207703414.21370.1.camel@heimdal.trondhjem.org>
	 <20080409082408.GA17458@infradead.org>
	 <1207746758.8303.4.camel@heimdal.trondhjem.org>
	 <20080409132721.GA23852@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>,
	Bryan Wu <cooloney@kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:19596 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754020AbYDINhf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Apr 2008 09:37:35 -0400
In-Reply-To: <20080409132721.GA23852@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-04-09 at 09:27 -0400, Christoph Hellwig wrote:
> On Wed, Apr 09, 2008 at 09:12:38AM -0400, Trond Myklebust wrote:
> > That is what this does. For the case of no mmu, generic_file_mmap()
> > compiles into a 'return -ENOSYS;'
> 
> doh, I was under the impression we had a real implementation now.
> Of course then it makes much more sense to just not set .mmap at all,
> which gives the same effect in a more obvious way and without any
> confusion to the reader.  (actually that one gives -ENODEV which I
> assume is for some reason more appropinquate)

I'm assuming there is a reason why the nommu folks want to return ENOSYS
rather than ENODEV when mmap() is unsupported by the hardware.

Bryan, any comments to that?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
