Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:63588 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750836AbaBCUnY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Feb 2014 15:43:24 -0500
Date: Mon, 3 Feb 2014 15:43:19 -0500
From: Tejun Heo <tj@kernel.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Dr Fields James Bruce <bfields@fieldses.org>,
        linuxnfs <linux-nfs@vger.kernel.org>, Li Zefan <lizefan@huawei.com>,
        containers@lists.linux-foundation.org, cgroups@vger.kernel.org
Subject: Re: [PATCH] nfs: include xattr.h from fs/nfs/nfs3proc.c
Message-ID: <20140203204319.GI30250@htj.dyndns.org>
References: <20140203193107.GH30250@htj.dyndns.org>
 <F2DD11A7-8D32-4E1E-BB4D-7384F0932B2D@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <F2DD11A7-8D32-4E1E-BB4D-7384F0932B2D@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 03, 2014 at 02:48:13PM -0500, Trond Myklebust wrote:
> 
> On Feb 3, 2014, at 14:31, Tejun Heo <tj@kernel.org> wrote:
> 
> > fs/nfs/nfs3proc.c is making use of xattr but was getting linux/xattr.h
> > indirectly through linux/cgroup.h, which will soon drop the inclusion
> > of xattr.h.  Explicitly include linux/xattr.h from nfs3proc.c so that
> > compilation doesn't fail when linux/cgroup.h drops linux/xattr.h.
> > 
> > As the following cgroup changes will depend on these changes, it
> > probably would be easier to route this through cgroup branch.  Would
> > that be okay?
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> > Cc: "J. Bruce Fields" <bfields@fieldses.org>
> 
> EWRONGMAINTAINER… :-)
> 
> Acked-by: Trond Myklebust <trond.myklebust@primarydata.com>

Oopsy, thanks! :)

-- 
tejun
