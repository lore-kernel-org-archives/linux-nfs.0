Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35003 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752913AbdEJNUM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 May 2017 09:20:12 -0400
Received: by mail-qk0-f180.google.com with SMTP id a72so29313806qkj.2
        for <linux-nfs@vger.kernel.org>; Wed, 10 May 2017 06:20:12 -0700 (PDT)
Message-ID: <1494422409.2688.13.camel@redhat.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>,
        Miklos Szeredi <mszeredi@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Date: Wed, 10 May 2017 09:20:09 -0400
In-Reply-To: <30059.1494403518@warthog.procyon.org.uk>
References: <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com>
         <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
         <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
         <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
         <10943.1494284264@warthog.procyon.org.uk>
         <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
         <15762.1494322915@warthog.procyon.org.uk>
         <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
         <1494355884.2659.18.camel@redhat.com>
         <30059.1494403518@warthog.procyon.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-10 at 09:05 +0100, David Howells wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
> > Possible rule of thumb: use it only at the place where the error
> > originates and not where errors are just passed on.  This would result
> > in at most one report per syscall, normally.
> >

That might be hard to enforce in practice once you get into some
complicated layering. What if we have device_mapper setting this along
with filesystems too? We need clear rules here.

> > And the static string thing that David implemented is also a very good
> > idea, IMO.
> 
> There is an issue with it: it's fine as long as you keep a ref on the module
> that generated it or clear all strings as part of module removal (which the
> mount context in this patchset does).  With the NFS mount context I did, I
> have to keep a ref on the NFS protocol module as well as the NFS filesystem
> module.
> 
> I'm tempted to make it conditionally copy the string using kvasprintf_const()
> - which would also permit format substitution.
> 

On balance, I think this is a reasonable way to pass back detailed
errors. Up until now, we've mostly relied on just printk'ing them. Now
though, a lot of larger machines are running containerized setups. Good
luck scraping dmesg for _your_ error in that situation. There may be
tons of mounts failing all over the place.

That said, I have some concerns here:

What's the lifetime of these strings? Do they just hang around forever
until the process goes away or they're replaced? If this becomes common,
then you could easily end up with an extra string allocation per task in
some cases. That could add up.

One idea might be to always kfree it on syscall entry, and that might
mitigate the problem assuming that not everything is erroring out. Then
you could always do some trivial syscall to clear it manually.

There's also the problem of how these should be formatted. Is English ok
everywhere? Do we need a facility to allow translating these things?
-- 
Jeff Layton <jlayton@redhat.com>
