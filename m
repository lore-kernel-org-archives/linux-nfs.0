Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f177.google.com ([209.85.216.177]:33987 "EHLO
        mail-qt0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753207AbdEJNsy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 May 2017 09:48:54 -0400
Received: by mail-qt0-f177.google.com with SMTP id j29so29722273qtj.1
        for <linux-nfs@vger.kernel.org>; Wed, 10 May 2017 06:48:53 -0700 (PDT)
Message-ID: <1494424131.2688.17.camel@redhat.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
From: Jeff Layton <jlayton@redhat.com>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Date: Wed, 10 May 2017 09:48:51 -0400
In-Reply-To: <CAOssrKeyUGCbAORH0ySA2WRBn7jLmPPNEBvvvyb0xMf67KsuCg@mail.gmail.com>
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
         <1494422409.2688.13.camel@redhat.com>
         <CAOssrKeyUGCbAORH0ySA2WRBn7jLmPPNEBvvvyb0xMf67KsuCg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2017-05-10 at 15:30 +0200, Miklos Szeredi wrote:
> On Wed, May 10, 2017 at 3:20 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Wed, 2017-05-10 at 09:05 +0100, David Howells wrote:
> > > Miklos Szeredi <mszeredi@redhat.com> wrote:
> > > 
> > > > Possible rule of thumb: use it only at the place where the error
> > > > originates and not where errors are just passed on.  This would result
> > > > in at most one report per syscall, normally.
> > > > 
> > 
> > That might be hard to enforce in practice once you get into some
> > complicated layering. What if we have device_mapper setting this along
> > with filesystems too? We need clear rules here.
> 
> If the error originates in the devicemapper, then why would the
> filesystem set it?
> 
> There's always a root cause of an error and that should be where the
> detailed error is set.
> 
> Am I missing something?
> 

I was thinking that you'd need some well-defined way to tell whether the
string should be replaced. If the thing just hangs out across syscalls,
then you don't know when it got put there. Is it a leftover from a
previous syscall or did a lower layer just put it there?

But...maybe I'm making assumptions about how this would work and I
should just wait until there are patches in flight. Getting the lifetime
of these strings right will be crucial though.

> > 
> > > > And the static string thing that David implemented is also a very good
> > > > idea, IMO.
> > > 
> > > There is an issue with it: it's fine as long as you keep a ref on the module
> > > that generated it or clear all strings as part of module removal (which the
> > > mount context in this patchset does).  With the NFS mount context I did, I
> > > have to keep a ref on the NFS protocol module as well as the NFS filesystem
> > > module.
> > > 
> > > I'm tempted to make it conditionally copy the string using kvasprintf_const()
> > > - which would also permit format substitution.
> > > 
> > 
> > On balance, I think this is a reasonable way to pass back detailed
> > errors. Up until now, we've mostly relied on just printk'ing them. Now
> > though, a lot of larger machines are running containerized setups. Good
> > luck scraping dmesg for _your_ error in that situation. There may be
> > tons of mounts failing all over the place.
> > 
> > That said, I have some concerns here:
> > 
> > What's the lifetime of these strings? Do they just hang around forever
> > until the process goes away or they're replaced? If this becomes common,
> > then you could easily end up with an extra string allocation per task in
> > some cases. That could add up.
> 
> That's why I liked the static string thing.  It's just one assignment
> and no worries about freeing.  Not sure what to do about modules,
> though.  Can we somehow move the cost of checking the validity to the
> place where the error is retrieved?
> 

Seems a little dangerous, and could be limiting. Dynamically allocated
strings seem like they could be more useful.

> > 
> > One idea might be to always kfree it on syscall entry, and that might
> > mitigate the problem assuming that not everything is erroring out. Then
> > you could always do some trivial syscall to clear it manually.
> > 
> > There's also the problem of how these should be formatted. Is English ok
> > everywhere? Do we need a facility to allow translating these things?
> 
> Messages in dmesg are in English too.  If necessary userspace will do
> the translation.  I don't think the kernel would need to worry about
> that.

Fair enough. It _is_ still an improvement over dmesg, IMO.
-- 
Jeff Layton <jlayton@redhat.com>
