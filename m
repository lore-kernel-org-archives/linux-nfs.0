Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49913 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752248AbbLOOEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Dec 2015 09:04:40 -0500
Date: Tue, 15 Dec 2015 09:04:39 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: dros@primarydata.com, Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Message-ID: <20151215140439.GA16093@fieldses.org>
References: <1385068813-5491-1-git-send-email-dros@netapp.com>
 <20151214221816.GA7342@fieldses.org>
 <20151214222154.GB7342@fieldses.org>
 <CAHQdGtQZwpa7kLypWjXrqDXWLvozErcCvEwbro_h1Kk7sGTYRw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQZwpa7kLypWjXrqDXWLvozErcCvEwbro_h1Kk7sGTYRw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 14, 2015 at 06:27:20PM -0500, Trond Myklebust wrote:
> On Mon, Dec 14, 2015 at 5:21 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > From: Weston Andros Adamson <dros@netapp.com>
> >
> > Fix a bug where getxattr returns ERANGE when the attr buffer
> > length is close enough to the nearest PAGE_SIZE multiple that adding
> > the extra bytes leaves too little room for the ACL buffer.
> >
> > Besides storing the ACL buffer, the getacl decoder uses the inline
> > pages for the attr bitmap and buffer length. __nfs4_get_acl_uncached
> > must allocate enough page space for all of the data to be decoded.
> >
> > This patch uses xdr_partial_copy_from_skb to allocate any needed
> > pages past the first one. This allows the client to always cache the acl
> > on the first getacl call and not just if it fits in one page.
> >
> > Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> The thread ends with:
> 
> "Indeed, buf->page_len is still set to the maximum number of bytes in
> the pages array (set by xdr_inline_pages to tell xdr layer the max
> allocation size), and not the number of bytes that are actually
> present.
> 
> Working on a fix.

Oh, apologies, for some reason I misfiled the rest of that thread.  But
I see it in online archives.  I'll take a look....

--b.
