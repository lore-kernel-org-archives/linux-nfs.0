Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:35918 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752856AbdEIMiu (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 08:38:50 -0400
Received: by mail-qt0-f170.google.com with SMTP id m91so75149284qte.3
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 05:38:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15868.1494323804@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
 <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
 <15868.1494323804@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Tue, 9 May 2017 14:38:48 +0200
Message-ID: <CAOssrKdJbobwX8Ns+2xq0OhdzZSOy5XmD-rKbJdWXGL6eWJkGQ@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 9, 2017 at 11:56 AM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> So say we have commands like
>>
>> "o+ foo"
>> "o- bar"
>
> The convention seems to be to prepend "no" to things you want to disable, so
> let's stick with that, e.g.:
>
>         "o foo"
>         "o nobar"
>
> otherwise we will have to have separate parsers for old mount() and the new sb
> config code - and not just for NFS, but at least for ext2/3/4 also.
>
> Further, we can only publish one format in /proc/mounts - and we cannot change
> that from the foo/nofoo standard we already use as it's part of the UAPI.

You're right, that this is a complicated issue and worth more
discussion.  And also you are right that we cannot change existing
UAPI, which is going to cause some headaches.

But that doesn't mean the new UAPI must follow the conventions of the
badly defined existing UAPI.

And the "no*" convention is anything but well defined, so we cannot
just stick it into generic code, because you'll find exceptions
everywhere.

And one more reason to have a new, unambiguous UAPI for retrieving
superblock options.

>
>> The generic option parser would just add or remove the option in the
>> current set of options,
>
> It sounds like you want to build up a string of "opt1,opt2,opt3" then have the
> VFS add and remove things from it and then parse it into the filesystem's
> internal structures on "commit".

That would be the default operation, if the filesystem doesn't define
its own parser.

>> and commit would just call ->remount_fs() with the new set of options.
>
> You're defining "commit" to do different things depending on the situation.
> You need a separation between "commit create" and "commit update".

It would be different, yes, at least until the superblock creation api
is completely transformed, at which point it may actually become the
same thing.  But lets not jump ahead.

>> It would probably not work for the NFS case, but that's okay, NFS can
>> implement its own option parsing.
>
> If NFS has to implement its own option parsing, we've done it wrong.

My above sentence was not clear.  What I meant to say that NFS needs
to implement the non-generic option parsing function in order to be
able to handle the case of "you can't change the server IP address".
Which it would want to do anyway, since it will result in cleaner
code.

Thanks,
Miklos
