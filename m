Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54274 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932420AbaHYULt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Aug 2014 16:11:49 -0400
Date: Mon, 25 Aug 2014 16:11:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-fsdevel@vger.kernel.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 04/10] locks: clean up vfs_setlease kerneldoc comments
Message-ID: <20140825201146.GC21957@fieldses.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
 <1408804878-1331-5-git-send-email-jlayton@primarydata.com>
 <20140824155117.GC15908@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140824155117.GC15908@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 24, 2014 at 08:51:17AM -0700, Christoph Hellwig wrote:
> On Sat, Aug 23, 2014 at 10:41:12AM -0400, Jeff Layton wrote:
> > Some of the latter paragraphs seem ambiguous and just plain wrong.
> > In particular the break_lease comment makes no sense. We call
> > break_lease (and break_deleg) from all sorts of vfs-layer functions,
> > so there is clearly such a method.

Right, but there's no f_op->break_lease.  Anyway:

> > Also, we are close to being able to allow for "real" filesystem
> > setlease methods so remove the final comment about it not being a
> > full implementation yet.
> 
> I'd remove even more:
> 
> > + *
> > + * This will call the filesystem's setlease file method, if defined. Note that
> > + * there is no getlease method; instead, the filesystem setlease method should
> > + * call back to generic_setlease() to add a lease to the inode's lease list,
> > + * where fcntl_getlease() can find it.  Since fcntl_getlease() only reports
> > + * whether the current task holds a lease, a cluster filesystem need only do
> > + * this for leases held by processes on this node.
> >   */
> 
> If we'd ever want a full implementation I think we'd absolutely need
> the getlease method.  But instead of hypothetizing about future
> implementation I'd rather leave it to those actually implementing such
> support, if that ever happens.

I agree, that makes sense.

--b.
