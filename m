Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f47.google.com ([209.85.218.47]:36432 "EHLO
	mail-oi0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932667AbbLNX1V (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Dec 2015 18:27:21 -0500
Received: by oian133 with SMTP id n133so24209609oia.3
        for <linux-nfs@vger.kernel.org>; Mon, 14 Dec 2015 15:27:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151214222154.GB7342@fieldses.org>
References: <1385068813-5491-1-git-send-email-dros@netapp.com>
	<20151214221816.GA7342@fieldses.org>
	<20151214222154.GB7342@fieldses.org>
Date: Mon, 14 Dec 2015 18:27:20 -0500
Message-ID: <CAHQdGtQZwpa7kLypWjXrqDXWLvozErcCvEwbro_h1Kk7sGTYRw@mail.gmail.com>
Subject: Re: [PATCH] NFSv4: fix getacl ERANGE for some ACL buffer sizes
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Weston Andros Adamson <dros@netapp.com>, Trond.Myklebust@netapp.com,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 14, 2015 at 5:21 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> From: Weston Andros Adamson <dros@netapp.com>
>
> Fix a bug where getxattr returns ERANGE when the attr buffer
> length is close enough to the nearest PAGE_SIZE multiple that adding
> the extra bytes leaves too little room for the ACL buffer.
>
> Besides storing the ACL buffer, the getacl decoder uses the inline
> pages for the attr bitmap and buffer length. __nfs4_get_acl_uncached
> must allocate enough page space for all of the data to be decoded.
>
> This patch uses xdr_partial_copy_from_skb to allocate any needed
> pages past the first one. This allows the client to always cache the acl
> on the first getacl call and not just if it fits in one page.
>
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>

The thread ends with:

"Indeed, buf->page_len is still set to the maximum number of bytes in
the pages array (set by xdr_inline_pages to tell xdr layer the max
allocation size), and not the number of bytes that are actually
present.

Working on a fix.

-dros"

So no, I'm not taking this patch until someone fixes the issues
identified in the review.

Cheers
  Trond
