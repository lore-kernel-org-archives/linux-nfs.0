Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43004 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751347AbdEDKWZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 May 2017 06:22:25 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <87bmr939bg.fsf@rasmusvillemoes.dk>
References: <87bmr939bg.fsf@rasmusvillemoes.dk> <149382747487.30481.15428192741961545429.stgit@warthog.procyon.org.uk> <149382749941.30481.11685229083280551867.stgit@warthog.procyon.org.uk>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: dhowells@redhat.com, viro@zeniv.linux.org.uk,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, mszeredi@redhat.com
Subject: Re: [PATCH 3/9] VFS: Introduce a mount context
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Thu, 04 May 2017 11:22:22 +0100
Message-ID: <24143.1493893342@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Rasmus Villemoes <linux@rasmusvillemoes.dk> wrote:

> > +	if (fs_type->fsopen && fs_type->mc_size < sizeof(*mc))
> > +		BUG();
> 
> So ->mc_size can be 0 (i.e. not explicitly initialized) if fs_type does
> not have ->fsopen. OK.

I need to be able to handle filesystems that don't support this yet.  Once all
filesystems support this, I would be able to take away the max_t() thing.

> > +	if (!src->ops->dup)
> > +		return ERR_PTR(-ENOTSUPP);
> > +
> > +	mc = kmemdup(src, src->fs_type->mc_size, GFP_KERNEL);
> 
> So this assumes that vfs_dup_mount_context is only used if ->mc_size is
> explicitly initialized. A max_t here as well probably wouldn't hurt.

If you don't provide an ->fsopen() op, you can't set src->ops, you don't see a
mount context and you can't call this function.  If you did supply an
->fsopen() op, the BUG() would've got you if you didn't set ->mc_size.

> > +	unsigned short mc_size;		/* Size of mount context to allocate */
> 
> Any particular reason to use a short? The struct doesn't pack any better.

But it leaves a hole someone else can use.  I try not to use fields larger
than I need to.

David
