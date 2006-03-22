From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [GIT] NFS client update for 2.6.16
Date: Wed, 22 Mar 2006 06:35:12 -0500
Message-ID: <1143027313.12871.27.camel@lade.trondhjem.org>
References: <1142961077.7987.14.camel@lade.trondhjem.org>
	<20060321174634.GA15827@infradead.org>
	<1142964532.7987.61.camel@lade.trondhjem.org>
	<20060321185734.GB19125@infradead.org>
	<1142967981.7987.92.camel@lade.trondhjem.org>
	<44205003.8070702@citi.umich.edu> <20060322103044.GB7025@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfsv4@linux-nfs.org, Linus Torvalds <torvalds@osdl.org>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20060322103044.GB7025@infradead.org>
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

On Wed, 2006-03-22 at 10:30 +0000, Christoph Hellwig wrote:
> On Tue, Mar 21, 2006 at 02:12:03PM -0500, Chuck Lever wrote:
> > i have been watching the multi-segment iovec work since then, and fully 
> > intended to add the support for readv/writev aio in the NFS direct path 
> > when the generic support becomes available.
> 
> 
> we agreed to not add another set of methods but rather consolidate the
> existing two sets of aio and vectored methods into one.  So to merge the
> core support all users including nfs need to be updated.  the last wip
> patchset is posted in the at:
> 
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177713027505&w=2
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177739515518&w=2
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177739313588&w=2
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=114177739407636&w=2
> 
> any nfs work should happen ontop of that.
> 
> I'm sill the opinion removing the iovec arguments isn't helpfull, but
> it's your code and if you think it helps you move forwarg go ahead with
> this.

Adding multi-segment support on top of this is not going to be a huge
job since the new code already does a form of multi-segment tracking in
the lower layers. By that I mean that it has to convert an arbitrarily
sized user buffer into a series of asynchronous NFS requests to be put
on the wire and then track them until they have completed. That is
pretty much all you have to do for the multi-iovec case too.

Cheers,
  Trond
