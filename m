Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35865 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759792Ab1CDTd1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Mar 2011 14:33:27 -0500
Date: Fri, 4 Mar 2011 14:33:25 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Horman <nhorman@tuxdriver.com>
Cc: linux-nfs@vger.kernel.org, Trond Myklebust <Trond.Myklebust@netapp.com>,
        security@kernel.org, Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs4: Ensure that ACL pages sent over NFS were not
 allocated from the slab
Message-ID: <20110304193325.GB21260@fieldses.org>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
 <20110304171320.GA19496@fieldses.org>
 <20110304184505.GB10083@hmsreliant.think-freely.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110304184505.GB10083@hmsreliant.think-freely.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 04, 2011 at 01:45:06PM -0500, Neil Horman wrote:
> On Fri, Mar 04, 2011 at 12:13:21PM -0500, J. Bruce Fields wrote:
> > On Fri, Mar 04, 2011 at 11:44:13AM -0500, Neil Horman wrote:
> > > We can't create a buffer with kmalloc and free it later in the tcp
> > > ack path with put_page, so we need to either:
> > 
> > But out of curiosity: why is there this rule?
> > 
> Its an artifact the results from needing to free memory using a method
> in keeping with the way in which it was allocated.  To use this bug as
> an example, the acl data was allocated by the VFS using kmalloc, which
> gets data from the slab.  Even though this data is a size that is a
> multiple of a page, slab objects can be less than a page, and multiple
> objects can be stored in a single page.  As such, anything allocated
> from the slab allocator needs to be freed by the slab allocator, so
> that object reference counts internally maintained by the slab can be
> kept accurate.  

OK.  I guess my naive mental model was that the slab allocator was
layered on top of the page allocator--so it got pages with alloc_pages()
or equivalent, then handed out pieces of them to people using the slab
allocator.

So I assumed the slab allocator would hold a reference to the page like
any other user would, in which case the tcp code could take a second
reference of its own.

--b.
