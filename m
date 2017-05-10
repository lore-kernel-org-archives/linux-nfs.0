Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:33359 "EHLO
        mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751121AbdEJHY3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 10 May 2017 03:24:29 -0400
Received: by mail-lf0-f50.google.com with SMTP id r17so14575290lfg.0
        for <linux-nfs@vger.kernel.org>; Wed, 10 May 2017 00:24:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1494355884.2659.18.camel@redhat.com>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
 <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
 <15762.1494322915@warthog.procyon.org.uk> <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
 <1494355884.2659.18.camel@redhat.com>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Wed, 10 May 2017 09:24:26 +0200
Message-ID: <CAOssrKdKmhUZtDja+SqHy_wPreyvE=oi90E+_uR_KPCOE-iHnw@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: Jeff Layton <jlayton@redhat.com>
Cc: David Howells <dhowells@redhat.com>,
        viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 9, 2017 at 8:51 PM, Jeff Layton <jlayton@redhat.com> wrote:
> On Tue, 2017-05-09 at 14:02 +0200, Miklos Szeredi wrote:
>> On Tue, May 9, 2017 at 11:41 AM, David Howells <dhowells@redhat.com> wrote:
>> > Miklos Szeredi <mszeredi@redhat.com> wrote:
>> >
>> > > I think that's crazy.  We don't return detailed errors for any other
>> > > syscall for path lookup, so why would path lookup for mount be
>> > > special.
>> >
>> > Firstly, we don't return detailed errors for mount() at the moment either.
>> >
>> > Secondly, path lookup might entail automounts, so perhaps we should do it for
>> > path lookup too.  Particularly in light of the fact that NFS4 mount uses
>> > pathwalk to get from server:/ to server:/the/dir/I/actually/wanted/ so I'm
>> > currently losing that error:-/
>> >
>> > Thirdly, the security operation I'm talking about is separate to path lookup -
>> > though perhaps we should pass LOOKUP_MOUNT as an intent flag into pathwalk so
>> > that the security check can be done there; perhaps combined with another one.
>> >
>> > Fourthly, why shouldn't we consider extending the facility to other system
>> > calls in future?  It would involve copying the string to task_struct and
>> > providing a way to retrieve it, but that's not that hard to achieve.
>>
>> Maybe we should.   In fact that sounds like a splendid idea.  IMO even
>> better, than having errors go via the fsfd descriptor.  Pretty cheap
>> on the kernel side, and completely optional on the userspace side.
>>
>
> A question here: What should happen if you go to set an error here, and
> one is already set? Should it just free the string and replace it with
> the new one? IOW, just keep the latest error? Or is it better to keep
> the earlier one?
>
> If you want to put this in the task_struct then I think you'll want to
> sort that out. You could easily end up in this situation if a lot of
> different kernel subsystems started using it to pass back detailed
> errors.

Possible rule of thumb: use it only at the place where the error
originates and not where errors are just passed on.  This would result
in at most one report per syscall, normally.

And the static string thing that David implemented is also a very good
idea, IMO.

So it would look something like this (possibly needs better naming:

   error_detail("description of error");

or

   return error_detail(-EINVAL, "description of error");

Compiler could automatically include source file/line information as
well, although it may be enough if the string is uniquely greppable
(we could check uniqueness at compile time).

Thanks,
Miklos
