Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59789 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752814AbaDDOB1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Apr 2014 10:01:27 -0400
Date: Fri, 4 Apr 2014 10:01:24 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, lmcilroy@redhat.com
Subject: Re: [PATCH] nfs: don't pass non-NULL-terminated string to
 pr_notice()
Message-ID: <20140404100124.2db49cb8@tlielax.poochiereds.net>
In-Reply-To: <5EC0B3CC-6647-4A6E-A44C-82A72CBEC490@primarydata.com>
References: <1396605654-10108-1-git-send-email-jlayton@redhat.com>
	<5EC0B3CC-6647-4A6E-A44C-82A72CBEC490@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 4 Apr 2014 09:51:11 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> 
> On Apr 4, 2014, at 6:00, Jeff Layton <jlayton@redhat.com> wrote:
> 
> > There is no guarantee that the strings in the nfs_cache_array will be
> > NULL-terminated. In the event that we end up hitting a readdir loop, we
> > need to ensure that we pass the warning message a properly-terminated
> > string.
> > 
> > Reported-by: Lachlan McIlroy <lmcilroy@redhat.com>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > fs/nfs/dir.c | 7 ++++---
> > 1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> > index 5c0b6ecc3a88..4689b125f9fe 100644
> > --- a/fs/nfs/dir.c
> > +++ b/fs/nfs/dir.c
> > @@ -304,12 +304,13 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
> > 				if (ctx->duped > 0
> > 				    && ctx->dup_cookie == *desc->dir_cookie) {
> > 					if (printk_ratelimit()) {
> > +						char *name = kstrndup(array->array[i].string.name, array->array[i].string.len, GFP_KERNEL);
> > +
> > 						pr_notice("NFS: directory %pD2 contains a readdir loop."
> > 								"Please contact your server vendor.  "
> > 								"The file: %s has duplicate cookie %llu\n",
> > -								desc->file,
> > -								array->array[i].string.name,
> > -								*desc->dir_cookie);
> > +								desc->file, name, *desc->dir_cookie);
> > +						kfree(name);
> > 					}
> 
> Umm… Any reason why we couldn’t just use ‘%.*s’ ?
> 

No reason at all. I had never run across that...

I'll respin and repost -- thanks!
-- 
Jeff Layton <jlayton@redhat.com>
