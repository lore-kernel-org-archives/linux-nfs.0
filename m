Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35363 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750707AbdAXRXO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 12:23:14 -0500
Received: by mail-qt0-f174.google.com with SMTP id x49so192993490qtc.2
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 09:23:14 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 10.2 \(3259\))
Subject: Re: regression in DIO write behavior
From: Weston Andros Adamson <dros@monkey.org>
In-Reply-To: <1485272659.3143.18.camel@redhat.com>
Date: Tue, 24 Jan 2017 12:23:12 -0500
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <963DBD29-C835-4716-9EAE-74C2EACA427F@monkey.org>
References: <1485272659.3143.18.camel@redhat.com>
To: Jeffrey Layton <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey Jeff,

That sounds like a regression to me. I don't think it's been around since the
pgio rework, but maybe?

-dros

> On Jan 24, 2017, at 10:44 AM, Jeff Layton <jlayton@redhat.com> wrote:
> 
> I've noticed a probable regression in recent kernels. When you run the
> attached program on an older kernel (I used 2.6.32-642.6.2.el6.x86_64),
> I see the kernel generate wsize WRITE calls on the wire.
> 
> When I run the same program on a more modern kernel (mainline as of
> today), it generates a ton of page-sized I/Os instead. I've verified
> that iov_iter_get_pages_alloc is returning a wsize array of pages, it
> just seems like the request handling code isn't stitching them together
> like it should.
> 
> Is this an expected change or a regression? I'm guessing the latter, and
> that it might have crept in during the pageio rework from a couple of
> years ago.
> 
> Any idea where the bug might be?
> -- 
> Jeff Layton <jlayton@redhat.com><diotest2.c>

