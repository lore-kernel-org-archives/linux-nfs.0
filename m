From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [GIT] Please pull NFS client fixes against linux-2.6.25-rc8
Date: Wed, 09 Apr 2008 09:12:38 -0400
Message-ID: <1207746758.8303.4.camel@heimdal.trondhjem.org>
References: <1207703414.21370.1.camel@heimdal.trondhjem.org>
	 <20080409082408.GA17458@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756175AbYDINMw@vger.kernel.org>
In-Reply-To: <20080409082408.GA17458@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-04-09 at 04:24 -0400, Christoph Hellwig wrote:
> > +#ifdef CONFIG_MMU
> >  	.mmap		= nfs_file_mmap,
> > +#else
> > +	.mmap		= generic_file_mmap,
> > +#endif
> 
> This is with almost 100% chance wrong.  It might get you a kernel that
> compiles but none where mmap actually works.  Just disable mmap on nfs
> for mmu-less systems until someone hacks up a proper mmu-less mmap
> method for nfs.

That is what this does. For the case of no mmu, generic_file_mmap()
compiles into a 'return -ENOSYS;'

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
