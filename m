Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:35550 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752654AbdEIMC7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 9 May 2017 08:02:59 -0400
Received: by mail-qt0-f173.google.com with SMTP id n4so74001858qte.2
        for <linux-nfs@vger.kernel.org>; Tue, 09 May 2017 05:02:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <15762.1494322915@warthog.procyon.org.uk>
References: <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
 <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
 <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com>
 <10943.1494284264@warthog.procyon.org.uk> <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
 <15762.1494322915@warthog.procyon.org.uk>
From: Miklos Szeredi <mszeredi@redhat.com>
Date: Tue, 9 May 2017 14:02:57 +0200
Message-ID: <CAOssrKeR4bNwYyuwyr2d5fG8RcxeyWKREFTdnGqovus9t_2n4A@mail.gmail.com>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
To: David Howells <dhowells@redhat.com>
Cc: viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 9, 2017 at 11:41 AM, David Howells <dhowells@redhat.com> wrote:
> Miklos Szeredi <mszeredi@redhat.com> wrote:
>
>> I think that's crazy.  We don't return detailed errors for any other
>> syscall for path lookup, so why would path lookup for mount be
>> special.
>
> Firstly, we don't return detailed errors for mount() at the moment either.
>
> Secondly, path lookup might entail automounts, so perhaps we should do it for
> path lookup too.  Particularly in light of the fact that NFS4 mount uses
> pathwalk to get from server:/ to server:/the/dir/I/actually/wanted/ so I'm
> currently losing that error:-/
>
> Thirdly, the security operation I'm talking about is separate to path lookup -
> though perhaps we should pass LOOKUP_MOUNT as an intent flag into pathwalk so
> that the security check can be done there; perhaps combined with another one.
>
> Fourthly, why shouldn't we consider extending the facility to other system
> calls in future?  It would involve copying the string to task_struct and
> providing a way to retrieve it, but that's not that hard to achieve.

Maybe we should.   In fact that sounds like a splendid idea.  IMO even
better, than having errors go via the fsfd descriptor.  Pretty cheap
on the kernel side, and completely optional on the userspace side.

>
>> And why would
>>
>>     fd = open("/foo/bar", O_PATH);
>>     fsmount(fsfd, fd, NULL);
>>
>> behave differently from
>>
>>     fsmount(fsfd, -1, "/foo/bar");
>>
>> ?
>
> There's argument that the former should return EFAULT.  And that you should
> set the path to "" and pass AT_EMPTY_PATH.  I should probably make sure it
> does that - and add a flags field.  statx() was fixed to work this way.
>
> Question for you: Should the MNT_* flags be passed to fsmount(), perhaps in
> MS_* form?

MS_* flags are a mess.  I don't think they should be used for any new
functionality.  MNT_* flags are much better, but there are some
internal flags there as well.

I think the struct file model is better, where we have the external
O_* flags and the internal FMODE_* flags.

Thanks,
Miklos
