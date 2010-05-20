Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52466 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034Ab0ETCV1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 22:21:27 -0400
Date: Wed, 19 May 2010 22:21:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Jeff Layton <jlayton@redhat.com>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
	file
Message-ID: <20100520022108.GC14940@fieldses.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net> <1273859968.4732.22.camel@localhost.localdomain> <1273861872.4732.34.camel@localhost.localdomain> <20100514192327.GA20192@fieldses.org> <20100519161419.GB1693@shareable.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100519161419.GB1693@shareable.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, May 19, 2010 at 05:14:19PM +0100, Jamie Lokier wrote:
> J. Bruce Fields wrote:
> > I'm not sure ading break_lease() to may_delete() is right, but maybe
> > it's better than nothing.
> > 
> > One problem is that there's a race: nothing I can see stops anyone from
> > getting another lease after may_delete() but before the delete happens.
> 
> Presumably the intent is that the NFSv4 REMOVE request _acquires_ the
> lease, and releases it after the delete is done.

It acquires something that prevents conflicting leases from being
granted, yes.  (Dunno if I'd call the thing that prevents conflicting
leases a "lease".)

> Same pattern with renames, attribute changes, etc.
> 
> Imho it would all be much tidier if leases had the same set of flag
> bits as inotify/dnotify, to say what changes they block.  (Maybe the
> flags would be slightly different - a detail).
> 
> All operations (read, write, open, link, rename, etc.) would follow a
> pattern like this pseudo-code:
> 
>    do_write(file)
>    {
>        err = lease_acquire(file, IN_MODIFY);

So I might call that "lease_deny" (or continue to call it
"lease_break").

>        if (err < 0)
>            return err;
> 
>        /* Do the modifying. */
> 
>        lease_release_and_inotify_event(file, IN_MODIFY);

Also, note the holder of the conflicting lease needs to be notified at
the start, not here.  (And the notification is synchronous--the
lease-holder gets to block the operation until it returns the lease.)

>    }
> 
> I think that would provide the semantics needed by NFS, Samba, also
> fanotify for free, and more or less any kind of userspace caching,
> coherent or not.  It's clean and orthogonal.  (Good value for money isn't it?)
> 
> The nlink value is missing from inotify (or "linked from" if you look
> at it differently), but that's a problem needing to be fixed anyway.

The interface sounds neat, sure.

I worry if it requires us to implement all of those mask bits at once.
Some might turn out to be more difficult to implement than others, and
we really only care about some of them for now.  I suppose there could
be a "supported_lease_mask_bits" value advertised to userspace.

--b.
