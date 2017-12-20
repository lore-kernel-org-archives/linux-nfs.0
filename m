Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50080 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756757AbdLTW4O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Dec 2017 17:56:14 -0500
Date: Wed, 20 Dec 2017 14:56:04 -0800
From: Matthew Wilcox <willy@infradead.org>
To: NeilBrown <neilb@suse.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] VFS: don't keep disconnected dentries on d_anon
Message-ID: <20171220225604.GA2980@bombadil.infradead.org>
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

s/a //

> +   the access.  As there is no parent, children, or name in the dentry
> +   is it unlikely that there will be any useful information to lose,
> +   and allocating a new dentry should normally be fast.

How about:

As the dentry is completely unattached, there is little information to
lose, and allocating a new dentry is normally fast.

