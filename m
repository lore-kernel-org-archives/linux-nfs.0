Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18776 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750945Ab1IURl3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Sep 2011 13:41:29 -0400
Date: Wed, 21 Sep 2011 13:41:15 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        samba-technical@lists.samba.org, Al Viro <viro@zeniv.linux.org.uk>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/6] leases: break read leases on unlink
Message-ID: <20110921174115.GH19441@pad.fieldses.org>
References: <1316617097-21384-1-git-send-email-bfields@redhat.com>
 <1316617097-21384-4-git-send-email-bfields@redhat.com>
 <20110921150241.GA11452@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110921150241.GA11452@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Sep 21, 2011 at 11:02:41AM -0400, Christoph Hellwig wrote:
> On Wed, Sep 21, 2011 at 10:58:14AM -0400, J. Bruce Fields wrote:
> > A read lease is used by NFSv4 as a guarantee that a client can perform
> > local read opens without informing the server.
> > 
> > The open operation takes the last component of the pathname as an
> > argument, thus is also a lookup operation, and giving the client the
> > above guarantee means informing the client before we allow anything that
> > would change the set of names pointing to the inode.
> 
> That seems like totally strange semantics.  A useful defintion of a
> lase operation would mean it guarantees I/O can happen, and wouldn't
> care about metadata operation.  That's the whole point in adding a
> stateful open to nfs4, isn't it?

One of the purposes of a delegation (==lease) is to let clients perform
open() entirely locally, without waiting for any round trips to the
server.

That doesn't work if the client has to revalidate the open path on every
open().

(And as I understand it--Trond can correct me if I'm
confused--revalidating at least the last component of the path is a
requirement for the close-to-open semantics that the Linux client
guarantees to applications.)

I dunno, perhaps a more logical way to do that would be to define some
kind of lease on the parent directories.  That's not the way the
protocols work.

--b.
