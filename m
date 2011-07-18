Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:48286 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752754Ab1GRRpR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2011 13:45:17 -0400
Date: Mon, 18 Jul 2011 18:45:15 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] nfs: don't use d_move in nfs_async_rename_done
Message-ID: <20110718174514.GD11013@ZenIV.linux.org.uk>
References: <1311002790-6650-1-git-send-email-jlayton@redhat.com>
 <1311010514.23313.4.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1311010514.23313.4.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Jul 18, 2011 at 01:35:14PM -0400, Trond Myklebust wrote:
> On Mon, 2011-07-18 at 11:26 -0400, Jeff Layton wrote: 
> > If the task that initiated the sillyrename ends up being killed by a
> > fatal signal, then it will eventually return back to userspace and end
> > up releasing the i_mutex. d_move however needs to be done while holding
> > the i_mutex.
> 
> Umm... Where is this requirement documented? I thought the rename_lock
> was there to protect against lookup races etc with d_move.

It protects lookup against d_move().  It does *NOT* protect the i_mutex
locking scheme from deadlocks a-sodding-plenty and it does not protect
->d_parent/->d_name accesses in directory methods (->i_mutex does).  The
latter is not a big deal, but the former is.

> Besides, NFS already has
> nfs_block_sillyrename()/nfs_unblock_sillyrename() to provide further
> exclusion between dentry lookups and revalidations and the silly-unlink
> code.

It's broken.  We are dealing with more than just NFS data structures.
Don't change ->d_parent unless you hold ->i_mutex on parent(s) involved
and if they are different you need ->s_vfs_rename_mutex as well.  See
lock_rename() in fs/namei.c and Documentation/filesystems/directory-locking.

Moreover, I would be very sceptical about the code trying to grap ->i_mutex
on ->d_parent of preexisting dentry, unless you have very good reasons to
be sure that it couldn't be moved around in the meanwhile.

d_move() in async rename is really broken...
