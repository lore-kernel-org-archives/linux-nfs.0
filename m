Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:40652 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbbKSWcX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Nov 2015 17:32:23 -0500
Date: Thu, 19 Nov 2015 17:32:20 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org,
        Eric Paris <eparis@parisplace.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH v1 31/38] nfs: replace d_add with d_splice_alias in
 atomic_open
Message-ID: <20151119223220.GC8506@fieldses.org>
References: <1447761180-4250-1-git-send-email-jeff.layton@primarydata.com>
 <1447761180-4250-32-git-send-email-jeff.layton@primarydata.com>
 <20151119200651.GB8506@fieldses.org>
 <20151119155931.2535b795@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151119155931.2535b795@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 19, 2015 at 03:59:31PM -0500, Jeff Layton wrote:
> Ahh right -- good point. d_splice_alias does this:
> 
>         if (!inode) {
>                 __d_instantiate(dentry, NULL);
>                 goto out;
>         }
> [...]
> out:
> 	security_d_instantiate(dentry, inode);
>         d_rehash(dentry);
>         return NULL;
> 
> ...which is exactly what d_add does. So yeah, that change isn't
> strictly necessary. Still, it might be more future-proof to use
> d_splice_alias there if the semantics ever change...

Could be, I don't know.

May as well apply it (or not) independently of this series, though.

--b.
