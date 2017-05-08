Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55988 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750836AbdEHIfw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 8 May 2017 04:35:52 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <22958.1493999242@warthog.procyon.org.uk>
References: <22958.1493999242@warthog.procyon.org.uk> <CAOssrKdHn5SpxEXBZ5EQvCF9E8JTiMqJo+M3OKPXUHYXGeqMGg@mail.gmail.com> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk>
To: Miklos Szeredi <mszeredi@redhat.com>
Cc: dhowells@redhat.com, viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Subject: Re: [RFC][PATCH 0/9] VFS: Introduce mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Mon, 08 May 2017 09:35:49 +0100
Message-ID: <31871.1494232549@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> > This patchset achieves this partly, but the separation is far from
> > crisp clear...  First of all why is fsopen() creating a "mount
> > context"?  It's suppsed to create a "superblock creation context".
> 
> I've no particular objection to renaming struct mount_context to something
> else, but it also needs to handle remount because of the commonality.
> 
> Further, once you've created a superblock, what are you going to do with it
> other than mount it?  I suppose you could statfs it and we could add other
> superblock manipulation functions, but this is normally done by opening the
> device directly (at least for bdev-based superblocks).

How about sb_context, sb_config, sb_parameters or something like that?

David
