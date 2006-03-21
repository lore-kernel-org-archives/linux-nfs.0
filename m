From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [GIT] NFS client update for 2.6.16
Date: Tue, 21 Mar 2006 13:58:01 -0500
Message-ID: <1142967482.7987.83.camel@lade.trondhjem.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org>
	<20060321174634.GA15827@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfsv4@linux-nfs.org, Linus Torvalds <torvalds@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060321174634.GA15827@infradead.org>
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

On Tue, 2006-03-21 at 17:46 +0000, Christoph Hellwig wrote:
> > commit 47989d7454398827500d0e73766270986a3b488f
> > Author: Chuck Lever <cel@netapp.com>
> > Date:   Mon Mar 20 13:44:32 2006 -0500
> > 
> >     NFS: remove support for multi-segment iovs in the direct write path
> >     
> >     Eliminate the persistent use of automatic storage in all parts of the
> >     NFS client's direct write path to pave the way for introducing support
> >     for aio against files opened with the O_DIRECT flag.
> 
> NACK.  We have patches pending that consolidate ->aio_read/write and
> ->read/writev into one operation.  this change is completely counterproductive
> towards that goal which has been discussed on -fsdevel for a while.

Could you, BTW, please post these pending patches? They are clearly not
in -mm, since these patches have been there for some time without
conflicting with anything else. The only references I could find were to
the following thread:

   http://thread.gmane.org/gmane.linux.file-systems/7748

which basically just adds a BUG() if you call NFS O_DIRECT with a
multi-segment iovec.

I can't see from those patches how Chuck's O_DIRECT changes can be
construed as being "counterproductive". AFAICS those changes are
completely orthogonal to your proposal.

Cheers,
  Trond
