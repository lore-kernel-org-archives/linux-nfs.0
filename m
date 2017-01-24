Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:33049 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750806AbdAXRuZ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Jan 2017 12:50:25 -0500
Received: by mail-qt0-f182.google.com with SMTP id v23so195579902qtb.0
        for <linux-nfs@vger.kernel.org>; Tue, 24 Jan 2017 09:50:24 -0800 (PST)
Message-ID: <1485280222.3143.25.camel@redhat.com>
Subject: Re: regression in DIO write behavior
From: Jeff Layton <jlayton@redhat.com>
To: Weston Andros Adamson <dros@monkey.org>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
        Scott Mayhew <smayhew@redhat.com>
Date: Tue, 24 Jan 2017 12:50:22 -0500
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

I certainly could be wrong. :)

I did open this bug, and we'll track it down there:

https://bugzilla.redhat.com/show_bug.cgi?id=1416127

Looks like Scott bisected it down in RHEL7 kernels so we should be able
to ID it from there.

Cheers,
Jeff

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

-- 
Jeff Layton <jlayton@redhat.com>
