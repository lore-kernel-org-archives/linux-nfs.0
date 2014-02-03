Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:56055 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008AbaBCT43 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 14:56:29 -0500
Received: by mail-ie0-f174.google.com with SMTP id tp5so6610170ieb.33
        for <linux-nfs@vger.kernel.org>; Mon, 03 Feb 2014 11:56:29 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH] nfs: include xattr.h from fs/nfs/nfs3proc.c
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140203193107.GH30250@htj.dyndns.org>
Date: Mon, 3 Feb 2014 14:48:13 -0500
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        linuxnfs <linux-nfs@vger.kernel.org>, Li Zefan <lizefan@huawei.com>,
        containers@lists.linux-foundation.org, cgroups@vger.kernel.org
Message-Id: <F2DD11A7-8D32-4E1E-BB4D-7384F0932B2D@primarydata.com>
References: <20140203193107.GH30250@htj.dyndns.org>
To: Tejun Heo <tj@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 3, 2014, at 14:31, Tejun Heo <tj@kernel.org> wrote:

> fs/nfs/nfs3proc.c is making use of xattr but was getting linux/xattr.h
> indirectly through linux/cgroup.h, which will soon drop the inclusion
> of xattr.h.  Explicitly include linux/xattr.h from nfs3proc.c so that
> compilation doesn't fail when linux/cgroup.h drops linux/xattr.h.
> 
> As the following cgroup changes will depend on these changes, it
> probably would be easier to route this through cgroup branch.  Would
> that be okay?
> 
> Signed-off-by: Tejun Heo <tj@kernel.org>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>

EWRONGMAINTAINER… :-)

Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>

> Cc: linux-nfs@vger.kernel.org
> ---
> fs/nfs/nfs3proc.c |    1 +
> 1 file changed, 1 insertion(+)
> 
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -18,6 +18,7 @@
> #include <linux/lockd/bind.h>
> #include <linux/nfs_mount.h>
> #include <linux/freezer.h>
> +#include <linux/xattr.h>
> 
> #include "iostat.h"
> #include "internal.h"
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Trond Myklebust
Linux NFS client maintainer

