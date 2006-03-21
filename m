From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [GIT] NFS client update for 2.6.16
Date: Tue, 21 Mar 2006 14:06:20 -0500
Message-ID: <1142967981.7987.92.camel@lade.trondhjem.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org>
	<20060321174634.GA15827@infradead.org>
	<1142964532.7987.61.camel@lade.trondhjem.org>
	<20060321185734.GB19125@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfsv4@linux-nfs.org, Linus Torvalds <torvalds@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060321185734.GB19125@infradead.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, 2006-03-21 at 18:57 +0000, Christoph Hellwig wrote:
> On Tue, Mar 21, 2006 at 01:08:52PM -0500, Trond Myklebust wrote:
> > We never had support for multiple iovecs in O_DIRECT, but were passing
> > around a single iovec entry deep into code that couldn't care less.
> 
> anthing that moves from iovecs back to plain buffers is counterproductive.
> The plan is that every fullblown fs will only deal with iovecs, onlt drivers
> and synthetic filesystems will implement the plain buffers.

You need to do more than just add an iovec argument to
nfs_file_direct_read()/nfs_file_direct_write() if you want to achieve
this. The new call interface actually just clarifies something that was
implicit in the old one.

As I said in my other posting, I believe Chuck's changes are relatively
orthogonal to what you want to do: they neither make the low-level
plumbing better or worse for readv()/writev().

We'd be happy to work with you in the run-up to 2.6.18 to add
multi-segment support for the existing patchsets. It makes more sense to
me to append that functionality to the existing patchsets rather than
trigger a complete rewrite (and thus have a sh_tload more code to
retest).

Cheers,
    Trond
