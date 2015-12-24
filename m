Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:34463 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751075AbbLXBhQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Dec 2015 20:37:16 -0500
Received: by mail-qk0-f181.google.com with SMTP id p187so166093097qkd.1
        for <linux-nfs@vger.kernel.org>; Wed, 23 Dec 2015 17:37:16 -0800 (PST)
Date: Wed, 23 Dec 2015 20:37:13 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Weston Andros Adamson <dros@primarydata.com>,
        Trond.Myklebust@netapp.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
Message-ID: <20151223203713.7c7daff8@tlielax.poochiereds.net>
In-Reply-To: <20151223165849.GA27432@fieldses.org>
References: <1385068813-5491-1-git-send-email-dros@netapp.com>
	<20151214221816.GA7342@fieldses.org>
	<20151214222154.GB7342@fieldses.org>
	<CAHQdGtQZwpa7kLypWjXrqDXWLvozErcCvEwbro_h1Kk7sGTYRw@mail.gmail.com>
	<20151223165849.GA27432@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 23 Dec 2015 11:58:49 -0500
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Dec 14, 2015 at 06:27:20PM -0500, Trond Myklebust wrote:
> > On Mon, Dec 14, 2015 at 5:21 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > > From: Weston Andros Adamson <dros@netapp.com>
> > >
> > > Fix a bug where getxattr returns ERANGE when the attr buffer
> > > length is close enough to the nearest PAGE_SIZE multiple that adding
> > > the extra bytes leaves too little room for the ACL buffer.
> > >
> > > Besides storing the ACL buffer, the getacl decoder uses the inline
> > > pages for the attr bitmap and buffer length. __nfs4_get_acl_uncached
> > > must allocate enough page space for all of the data to be decoded.
> > >
> > > This patch uses xdr_partial_copy_from_skb to allocate any needed
> > > pages past the first one. This allows the client to always cache the acl
> > > on the first getacl call and not just if it fits in one page.
> > >
> > > Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > The thread ends with:
> > 
> > "Indeed, buf->page_len is still set to the maximum number of bytes in
> > the pages array (set by xdr_inline_pages to tell xdr layer the max
> > allocation size), and not the number of bytes that are actually
> > present.
> > 
> > Working on a fix.
> > 
> > -dros"
> 
> Dros, do you have a reliable reproducer for the BUG you were seeing?
> I'm not having any luck.
> 
> --b.

I doubt Dros' netapp email addr still works. Sending to his PD one...

-- 
Jeff Layton <jeff.layton@primarydata.com>
