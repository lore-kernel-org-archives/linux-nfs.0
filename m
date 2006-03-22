From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] [GIT] NFS client update for 2.6.16
Date: Wed, 22 Mar 2006 10:25:22 +0000
Message-ID: <20060322102522.GA7025@infradead.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org>
	<20060321174634.GA15827@infradead.org>
	<1142967482.7987.83.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfsv4@linux-nfs.org, Linus Torvalds <torvalds@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1142967482.7987.83.camel@lade.trondhjem.org>
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

On Tue, Mar 21, 2006 at 01:58:01PM -0500, Trond Myklebust wrote:
> Could you, BTW, please post these pending patches? They are clearly not
> in -mm, since these patches have been there for some time without
> conflicting with anything else. The only references I could find were to
> the following thread:
> 
>    http://thread.gmane.org/gmane.linux.file-systems/7748
> 
> which basically just adds a BUG() if you call NFS O_DIRECT with a
> multi-segment iovec.

Yes, that's the latest public version.  and nfs is one of the last missing
items.
