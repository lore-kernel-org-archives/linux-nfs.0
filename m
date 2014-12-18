Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:64025 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751057AbaLRRc2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2014 12:32:28 -0500
Received: by mail-qg0-f53.google.com with SMTP id l89so1205918qgf.12
        for <linux-nfs@vger.kernel.org>; Thu, 18 Dec 2014 09:32:27 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 18 Dec 2014 12:32:23 -0500
To: "J. R. Okajima" <hooanon05g@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH] dcache: return -ESTALE not -EBUSY on distributed fs
 race
Message-ID: <20141218123223.6c88cdf1@tlielax.poochiereds.net>
In-Reply-To: <13170.1418920034@jrobl>
References: <20141217195911.GF9617@fieldses.org>
	<20141217200153.GG9617@fieldses.org>
	<12689.1418917838@jrobl>
	<20141218155838.GD18179@fieldses.org>
	<13170.1418920034@jrobl>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 19 Dec 2014 01:27:14 +0900
"J. R. Okajima" <hooanon05g@gmail.com> wrote:

> 
> "J. Bruce Fields":
> > Why do you think -EBUSY's the right error in the local filesystem case?
> 
> This busy_or_stale() is another bandaid, based upon your patch, EBUSY
> --> ESTALE.
> Because the msg string of ESTALE is "Stale NFS file handle" on many
> systems, I don't think it a good idea to return it for local fs. If you
> think EIO is better than EBUSY you can change it to eio_or_stale(). If
> you think it is surely not happen on every local fs, then this inline
> function is not necessary.
> 

I think the only way this could happen on a local fs would be for it to
allow hardlinked directories, which is (of course) forbidden. After
all, the comment above __d_unalias specifically mentions that it's
there to handle remotely renamed directories.

I think the patch is almost certainly fine for NFS. The only question
I'd have is whether other distributed filesystems (p9? ceph? gfs2?)
might have an issue here. It seems unlikely though, and most of them
would also benefit from redoing the lookup with LOOKUP_REVAL set in
this situation.

Still, it's probably worth letting this soak in -next for a bit to be
sure we're not missing anything.

Bruce, you can add my:

Acked-by: Jeff Layton <jlayton@primarydata.com>
