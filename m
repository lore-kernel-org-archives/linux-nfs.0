From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCHSET 0-6] nfsd: #includes cleanup
Date: Mon, 23 Nov 2009 17:14:15 -0500
Message-ID: <20091123221415.GE8534@fieldses.org>
References: <4B0AB039.6020608@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	NFS list <linux-nfs@vger.kernel.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B0AB039.6020608@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 23, 2009 at 05:54:33PM +0200, Boaz Harrosh wrote:
> 
> Hi Bruce
> 
> This time I've based the patchset on the:
> 	git://linux-nfs.org/~bfields/linux.git for-2.6.33 branch
> 
> I was hoping to find that nfsd.h cleanup you sent to the mailing list
> the other day. But I don't see it. Should I rebase this work on some
> other branch?

Apologies, I applied it but hadn't pushed it out; done now.  Could you
rebase onto that?

--b.

> would you like to submit that patch, which made lots of
> sense in my opinion, and I'll wait and base this work on that?
> [On the other we might be able to move the complete nfsd.h to fs/nfsd/]
> 
> I have gone deeper and wider this time. And it is based on upcoming
> main-line, not pnfs tree like before. So it can actually be applied
> this time. Please lets decide on some time table because these things
> are moving targets.
> 
> I've removed the hunk from posix_acl.h that Trond did not like, I'll
> take care of that one, another time. (For late comers, posix_acl.h intimately
> fiddles with fs.h types but does not #include it)
> 
> With these patches Benny will suffer on his next rebase, both in conflicts
> and a few miss-compiling files, but it should be trivial to fix, I'll help.
> 
> The next step after these patches, is to move lots of files from include/linux/nfsd/*
> to fs/nfsd/... I have found that the include/linux/nfsd/xdr?.h, nfsd.h and cache.h
> are all essentially only used by fs/nfsd source, except they are *wrongly* included by
> some compat.c source files. Once I'll fix that they can move.
> 
> [PATCH 1/6] nfsd: Remove nfsfh.h dependency on sunrpc
>     Bruce, what about this patch. It is independent of the others. Currently sunrpc
>     is loaded/unloaded with nfs or nfsd. exportfs and filesystems don't expect to need
>     it. It works because depmod is doing it's job. Do we really need this dprintk?
> 
> [PATCH 2/6] sunrpc: Clean never used include files
> [PATCH 3/6] nfsd: Fix independence of a few nfsd related headers
>     I wish these two patches could go through Bruce's tree as one group.
>     Who's ACKs do we need on them? Trond?
> 
> [PATCH 4/6] nfsd: Headers Independence and include cleanups
> [PATCH 5/6] nfsd: Source files #include cleanups
>     Please review these patches to understand the motivation behind all
>     this.
> 
> [PATCH 6/6] compat.c: Remove dependence on nfsd private headers
>     This patch is a beginning of the next step to move the nfsd private
>     headers to inside the fs/nfsd subdirectory.
> 
> Thanks
> Boaz
> 
