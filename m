Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55972 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbdEKHYj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 May 2017 03:24:39 -0400
Date: Thu, 11 May 2017 08:24:37 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: mszeredi@redhat.com, jlayton@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 06/14] VFS: Introduce a superblock configuration context
Message-ID: <20170511072437.GK390@ZenIV.linux.org.uk>
References: <149443309780.2378.6532276992468576087.stgit@warthog.procyon.org.uk>
 <149443315971.2378.14729909191942288079.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <149443315971.2378.14729909191942288079.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 10, 2017 at 05:19:19PM +0100, David Howells wrote:
> + (*) struct mnt_namespace *mnt_ns
> +
> +     This is a subset of the namespaces in use by the invoking process.  This
> +     retains a ref on each namespace.  The subscribed namespaces may be
> +     replaced by the filesystem to reflect other sources, such as the parent
> +     mount superblock on an automount.

I don't think it's a good idea.  No comments on userns stuff, but what's
the situation when you want it to play with the real namespace?  Details,
please...

> + (*) int (*fill_super)(struct super_block *s, struct sb_config *sc);
> +
> +     This is available to be used by things like mount_ns_mc() that are called
> +     by ->mount() to transfer information/resources from the superblock configuration context to
> +     the superblock.

        Don't.  This kind of stuff can bloody well be an explicit callback.
Methods of that kind are trouble - we had that sort of PITA quite a few
times, and it had always been a headache when we eventually had to kill them
off.  Starting with ->read_inode(), if you remember that one...
