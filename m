Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:36650 "EHLO
        mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbdAXTqb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 14:46:31 -0500
Received: by mail-yw0-f171.google.com with SMTP id v200so171312190ywc.3
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 11:46:31 -0800 (PST)
Message-ID: <1485287189.3143.29.camel@redhat.com>
Subject: Re: regression in DIO write behavior
From: Jeff Layton <jlayton@redhat.com>
To: Weston Andros Adamson <dros@monkey.org>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Date: Tue, 24 Jan 2017 14:46:29 -0500
In-Reply-To: <963DBD29-C835-4716-9EAE-74C2EACA427F@monkey.org>
References: <1485272659.3143.18.camel@redhat.com>
         <963DBD29-C835-4716-9EAE-74C2EACA427F@monkey.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2017-01-24 at 12:23 -0500, Weston Andros Adamson wrote:
> Hey Jeff,
> 
> That sounds like a regression to me. I don't think it's been around since the
> pgio rework, but maybe?
> 
> -dros
> 
> > On Jan 24, 2017, at 10:44 AM, Jeff Layton <jlayton@redhat.com> wrote:
> > 
> > I've noticed a probable regression in recent kernels. When you run the
> > attached program on an older kernel (I used 2.6.32-642.6.2.el6.x86_64),
> > I see the kernel generate wsize WRITE calls on the wire.
> > 
> > When I run the same program on a more modern kernel (mainline as of
> > today), it generates a ton of page-sized I/Os instead. I've verified
> > that iov_iter_get_pages_alloc is returning a wsize array of pages, it
> > just seems like the request handling code isn't stitching them together
> > like it should.
> > 
> > Is this an expected change or a regression? I'm guessing the latter, and
> > that it might have crept in during the pageio rework from a couple of
> > years ago.
> > 
> > Any idea where the bug might be?
> > -- 
> > Jeff Layton <jlayton@redhat.com><diotest2.c>
> 
> 

Ahh, I think I might get it now and it's not as bad as I had originally
feared...

If you dirty all of the pages before writing, it seems to coalesce them
correctly. The reproducer allocates pages, but doesn't actually dirty
them before writing them. Apparently the allocator is setting up the
mapping such that each page offset address in the allocation points to
the same page. I imagine it's then setting up that page for CoW.

So we end up in this test in nfs_can_coalesce_requests and hit the
return false:

                if (req->wb_page == prev->wb_page) {
                        if (req->wb_pgbase != prev->wb_pgbase + prev->wb_bytes)
                                return false;

I think that's in place to handle sub-page write requests, but maybe we
should consider doing that a different way for DIO?
-- 
Jeff Layton <jlayton@redhat.com>
