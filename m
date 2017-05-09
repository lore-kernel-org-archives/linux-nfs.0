Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752649AbdEIJl6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 May 2017 05:41:58 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com>
References: <CAOssrKexeO8mmFFAPq2jQtO06iqGWDDe8BOUktEkY6UybDBX1Q@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk> <CAOssrKc0=geAw04btF9zO29y3=2sP+caF90HySKMbk8NkND3kQ@mail.gmail.com> <10943.1494284264@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Tue, 09 May 2017 10:41:55 +0100
Message-ID: <15762.1494322915@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> I think that's crazy.  We don't return detailed errors for any other
> syscall for path lookup, so why would path lookup for mount be
> special.

Firstly, we don't return detailed errors for mount() at the moment either.

Secondly, path lookup might entail automounts, so perhaps we should do it for
path lookup too.  Particularly in light of the fact that NFS4 mount uses
pathwalk to get from server:/ to server:/the/dir/I/actually/wanted/ so I'm
currently losing that error:-/

Thirdly, the security operation I'm talking about is separate to path lookup -
though perhaps we should pass LOOKUP_MOUNT as an intent flag into pathwalk so
that the security check can be done there; perhaps combined with another one.

Fourthly, why shouldn't we consider extending the facility to other system
calls in future?  It would involve copying the string to task_struct and
providing a way to retrieve it, but that's not that hard to achieve.

> And why would
> 
>     fd = open("/foo/bar", O_PATH);
>     fsmount(fsfd, fd, NULL);
> 
> behave differently from
> 
>     fsmount(fsfd, -1, "/foo/bar");
> 
> ?

There's argument that the former should return EFAULT.  And that you should
set the path to "" and pass AT_EMPTY_PATH.  I should probably make sure it
does that - and add a flags field.  statx() was fixed to work this way.

Question for you: Should the MNT_* flags be passed to fsmount(), perhaps in
MS_* form?

David
