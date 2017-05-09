Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47694 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752016AbdEIJ4r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 May 2017 05:56:47 -0400
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
Date: Tue, 09 May 2017 10:56:44 +0100
Message-ID: <15868.1494323804@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Miklos Szeredi <mszeredi@redhat.com> wrote:

> So say we have commands like
> 
> "o+ foo"
> "o- bar"

The convention seems to be to prepend "no" to things you want to disable, so
let's stick with that, e.g.:

	"o foo"
	"o nobar"

otherwise we will have to have separate parsers for old mount() and the new sb
config code - and not just for NFS, but at least for ext2/3/4 also.

Further, we can only publish one format in /proc/mounts - and we cannot change
that from the foo/nofoo standard we already use as it's part of the UAPI.

> The generic option parser would just add or remove the option in the
> current set of options,

It sounds like you want to build up a string of "opt1,opt2,opt3" then have the
VFS add and remove things from it and then parse it into the filesystem's
internal structures on "commit".

> and commit would just call ->remount_fs() with the new set of options.

You're defining "commit" to do different things depending on the situation.
You need a separation between "commit create" and "commit update".

> It would probably not work for the NFS case, but that's okay, NFS can
> implement its own option parsing.

If NFS has to implement its own option parsing, we've done it wrong.

David
