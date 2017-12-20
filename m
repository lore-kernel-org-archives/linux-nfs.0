Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56044 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751955AbdLTXQz (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 18:16:55 -0500
Date: Wed, 20 Dec 2017 23:16:46 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] VFS: don't keep disconnected dentries on d_anon
Message-ID: <20171220231646.GW21978@ZenIV.linux.org.uk>
References: <87y3lxj9wr.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87y3lxj9wr.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 21, 2017 at 09:45:40AM +1100, NeilBrown wrote:

> -c/ Helper routines to allocate anonymous dentries, and to help attach
> +   prefix.  If the refcount on a dentry with this flag set
> +   becomes zero, the dentry is immediately discarded, rather than being
> +   kept in the dcache.  If a dentry that is not already in the dcache
> +   is repeatedly accessed by filehandle (as NFSD might do), an new dentry
> +   will be a allocated for each access, and discarded at the end of
> +   the access.  As there is no parent, children, or name in the dentry
					  ^^^^^^^^
That part is where I have a problem with it.  Consider nfsd failing to
reconnect a growing subtree with the root.  It has managed to get to
some point, but then failed to get the parent for some reason (IO error, OOM,
anything).  Now we have a non-trivial subtree; its root does have children,
but it's not connected to anything.  It has been created by d_obtain_alias();
in __d_obtain_alias() IS_ROOT() had been true, and so was 'disconnected'
argument.

The question is not whether they carry any valuable information - it's
whether we are guaranteed that they won't need pruning on umount.  And
they will - the invariant we maintain is that all descendents will have
DCACHE_DISCONNECTED set until the sucker is reconnected to root.  That's
why they won't stick around - nothing in such subtree will be retained in
dcache once the refcount hits 0.

I believe that the actual changes are OK, but your explanation above is
wrong and the logics there is convoluted enough, so this needs to be
written accurately.

BTW, I would like comments from Lustre folks - the situation with dcache
in there is rather unusual.
