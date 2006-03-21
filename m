From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [GIT] NFS client update for 2.6.16
Date: Tue, 21 Mar 2006 18:57:34 +0000
Message-ID: <20060321185734.GB19125@infradead.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org>
	<20060321174634.GA15827@infradead.org>
	<1142964532.7987.61.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfsv4@linux-nfs.org, Linus Torvalds <torvalds@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1142964532.7987.61.camel@lade.trondhjem.org>
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

On Tue, Mar 21, 2006 at 01:08:52PM -0500, Trond Myklebust wrote:
> We never had support for multiple iovecs in O_DIRECT, but were passing
> around a single iovec entry deep into code that couldn't care less.

anthing that moves from iovecs back to plain buffers is counterproductive.
The plan is that every fullblown fs will only deal with iovecs, onlt drivers
and synthetic filesystems will implement the plain buffers.
