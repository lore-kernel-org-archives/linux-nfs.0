Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:35431 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755091AbdELIPs (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 May 2017 04:15:48 -0400
Received: by mail-wm0-f53.google.com with SMTP id b84so12756096wmh.0
        for <linux-nfs@vger.kernel.org>; Fri, 12 May 2017 01:15:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1494424131.2688.17.camel@redhat.com>
References: <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com>
 <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
 <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
 <15762.1494322915@warthog.procyon.org.uk> <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
 <1494355884.2659.18.camel@redhat.com> <30059.1494403518@warthog.procyon.org.uk>
 <1494422409.2688.13.camel@redhat.com> <CAOssrKeyUGCbAORH0ySA2WRBn7jLmPPNEBvvvyb0xMf67KsuCg@mail.gmail.com>
 <1494424131.2688.17.camel@redhat.com>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Fri, 12 May 2017 10:15:45 +0200
Message-ID: <CAOssrKf=omY4ENEGXJCv7-aiEx8BOseFm_gEOVH6CtoshCsxTw@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: Jeff Layton <jlayton@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 10, 2017 at 3:48 PM, Jeff Layton <jlayton@redhat.com> wrote:

> I was thinking that you'd need some well-defined way to tell whether the
> string should be replaced. If the thing just hangs out across syscalls,
> then you don't know when it got put there. Is it a leftover from a
> previous syscall or did a lower layer just put it there?

Example userspace code:

    /* Throw away previous error string */
    get_detailed_error(NULL, 0);
    ret = somesyscall(...);
    if (ret == -1) {
        char errbuf[1024];

        /* Get detailed error string for somesyscall */
        get_detailed_error(errbuf, sizeof(errbuf));
        err(1, errbuf);
    }

>> That's why I liked the static string thing.  It's just one assignment
>> and no worries about freeing.  Not sure what to do about modules,
>> though.  Can we somehow move the cost of checking the validity to the
>> place where the error is retrieved?
>>
>
> Seems a little dangerous,

True.

>  and could be limiting. Dynamically allocated
> strings seem like they could be more useful.

Overdesign always starts with that.  A static string is infinitely
more descriptive than an error num, and we've done pretty well with
the latter, so I'm not convinced that we really need a formatted
string.

Maybe just use kstrdup_const() if CONFIG_MODULE_UNLOAD is set,
otherwise plain assignment.  Then free the string when retrieving and
on task exit.

Thanks,
Miklos
