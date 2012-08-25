Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26280 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753112Ab2HYXbq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 25 Aug 2012 19:31:46 -0400
Message-ID: <1345937503.4943.17.camel@localhost>
Subject: Re: [PATCH] Avoid array overflow in __nfs4_get_acl_uncached
From: Sachin Prabhu <sprabhu@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Date: Sun, 26 Aug 2012 00:31:43 +0100
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908F5859F@SACEXCMBX01-PRD.hq.netapp.com>
References: <1345817768-23511-1-git-send-email-sprabhu@redhat.com>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F4AF1E@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345843866.2279.6.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5842F@SACEXCMBX01-PRD.hq.netapp.com>
	 <1345845062.32200.1.camel@localhost>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA908F5859F@SACEXCMBX01-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-08-24 at 22:02 +0000, Myklebust, Trond wrote:
> On Fri, 2012-08-24 at 22:51 +0100, Sachin Prabhu wrote:
> > On Fri, 2012-08-24 at 21:38 +0000, Myklebust, Trond wrote:
> > > On Fri, 2012-08-24 at 22:31 +0100, Sachin Prabhu wrote:
> > > > On Fri, 2012-08-24 at 15:07 +0000, Myklebust, Trond wrote:
> > > > > On Fri, 2012-08-24 at 15:16 +0100, Sachin Prabhu wrote:
> > > > > > This fixes a bug introduced by commit
> > > > > > 5a00689930ab975fdd1b37b034475017e460cf2a
> > > > > > The patch adds an extra page to npages to hold the bitmap returned by
> > > > > > the server.
> > > > > > 
> > > > > > Bruce Fields pointed out that the changes introduced by the patch will
> > > > > > cause the array npages to overflow if a buffer of size greater than or
> > > > > > equal to XATTR_SIZE_MAX is passed to __nfs4_get_acl_uncached()
> > > > > 
> > > > > I'd think that the right thing to do here is rather to add appropriate
> > > > > buffer overflow checks. How about something like the following?
> > > > > 
> > > > > 8<--------------------------------------------------------------
> > > > > From 7c35ce220924182284aea9f8aec39b0d991600df Mon Sep 17 00:00:00 2001
> > > > > From: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > > Date: Fri, 24 Aug 2012 10:59:25 -0400
> > > > > Subject: [PATCH] NFSv4: Fix range checking in __nfs4_get_acl_uncached and
> > > > >  __nfs4_proc_set_acl
> > > > > 
> > > > > Ensure that the user supplied buffer size doesn't cause us to overflow
> > > > > the 'pages' array.
> > > > > 
> > > > > Also fix up some confusion between the use of PAGE_SIZE and
> > > > > PAGE_CACHE_SIZE when calculating buffer sizes. We're not using
> > > > > the page cache for anything here.
> > > > > 
> > > > > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > > > 
> > > > This patch is susceptible to the problem described in commit
> > > > 5a00689930ab975fdd1b37b034475017e460cf2a
> > > > 
> > > > This can be demonstrated by the following patch to pynfs which pads the
> > > > bitmap with 1000 extra elements.
> > > > 
> > > > To reproduce, on the server
> > > > cd newpynfs/nfs4.0/
> > > > ./setup.py build_ext --inplace
> > > > ./nfs4server.py
> > > > 
> > > > on the client, 
> > > > mount -o vers=4 SERVER:/ /mnt
> > > > touch /mnt/a
> > > > nfs4_getfacl /mnt/a
> > > > 
> > > > With this new patch, you will get a general protection fault in
> > > > _copy_from_pages().
> > > 
> > > Is this on a kernel with commit 519d3959e30a98f8e135e7a16647c10af5ad63d5
> > > (NFSv4: Fix pointer arithmetic in decode_getacl) applied?
> > > 
> > 
> > Yes.
> 
> OK, so can you look into which parameters are incorrect and why? The
> checks in decode_getacl are supposed ensure that we don't overflow the
> xdr->buf->page_len, so if those are insufficient, then I'd like to
> understand why.
> 

The problem is seen because we do not check to see if the acl_len +
bitmap size is contained within the page buffer we allocate for it. 

It will fail if
bitmap array size + acl length attribute size + ACLs > pages allocated
for it.  

In this case, when we call nfs4_write_cached_acl() to write the returned
ACLs into cache, we call _copy_from_pages() to read from 
ie. We call nfs4_write_cached_acl
                nfs4_write_cached_acl(inode, pages, res.acl_data_offset,
                                      acl_len);
which in turn calls
static void nfs4_write_cached_acl(struct inode *inode, struct page
**pages, size_t pgbase, size_t acl_len)
{
..
                _copy_from_pages(acl->data, pages, pgbase, acl_len);
..
}

A simple example is if the ACL size is just less than a PAGE_SIZE but
large enough so that ACL + Bitmap crosses a PAGE_SIZE, it will fail.
Another example is if the server sends a large bitmap array along with
smaller ACL data causing the bitmap array + ACL to go past the allocated
page, it will fail again.

We exploit the bug using the second example given above. We configured
pynfs to append 1000 extra elements to the bitmap array which results in
BITMAP+ACL size to be little over a PAGE_SIZE. This leads to a General
Protection Fault in _copy_from_pages().
Using a simple printk in __nfs4_get_acl_uncached, I see the following
values
args.acl_len=4096, res.acl_data_offset=4012, res.acl_len=156
We end up calling 
_copy_from_pages(acl->data, pages, 4012, 156); 

When tested _without_ this patch, where the minimum npages sent is 2,
and the bitmap padding is set so that we cross 2*PAGESIZE,  we fail in
decode_attr_bitmap-> xdr_decode_inline
because we cross buffer boundary and the allocated scratch page is
insufficient to read the bitmap returned. Although it prevent the crash,
it is not the ideal solution to the problem.

Sachin Prabhu

