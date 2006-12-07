From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH 10/10] gfs2: nfs lock support for gfs2
Date: Thu, 07 Dec 2006 13:52:24 -0500
Message-ID: <1165517544.2903.4.camel@lade.trondhjem.org>
References: <20061207152359.GB13613@fieldses.org>
	 <OF3AAB0892.7839D917-ON8825723D.0055EEC9-8825723D.00563276@us.ibm.com>
	 <20061207162110.GA16858@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Marc Eshel <eshel@almaden.ibm.com>, linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20061207162110.GA16858@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2006-12-07 at 11:21 -0500, J. Bruce Fields wrote:
> On Thu, Dec 07, 2006 at 07:43:48AM -0800, Marc Eshel wrote:
> > nfs-bounces@lists.sourceforge.net wrote on 12/07/2006 07:23:59 AM:
> > 
> > > On Wed, Dec 06, 2006 at 10:47:46PM -0800, Marc Eshel wrote:
> > > >    if (!rv) { /* got fs lock */
> > > >        rv = posix_lock_file(file, fl);
> > > >        if (rv) { /* did not get posix lock */
> > > 
> > > If we never request the local lock until after we've gotten the lock
> > > from GFS, then this should never happen.  So I think this could just be
> > > a BUG_ON(rv)--except that would mean a failure in the lock manager could
> > > oops the kernel, so maybe it'd be better just to printk.
> > 
> > It can happen if you can not allocate memory. 
> 
> OK, you're right.
> 
> Hm, the NFS client just seems to print out a warning at this point,
> though.

Feel free to suggest alternatives. If you cannot even allocate the
memory necessary to add a struct file_lock, then how can you expect to
find enough resources to be able to marshall up an RPC call?

Trond

