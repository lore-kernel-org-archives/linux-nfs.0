Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:35423 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297AbaDDNvQ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Apr 2014 09:51:16 -0400
Received: by mail-ie0-f178.google.com with SMTP id lx4so3266172iec.23
        for <linux-nfs@vger.kernel.org>; Fri, 04 Apr 2014 06:51:16 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: [PATCH] nfs: don't pass non-NULL-terminated string to pr_notice()
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <1396605654-10108-1-git-send-email-jlayton@redhat.com>
Date: Fri, 4 Apr 2014 09:51:11 -0400
Cc: linux-nfs@vger.kernel.org, lmcilroy@redhat.com
Message-Id: <5EC0B3CC-6647-4A6E-A44C-82A72CBEC490@primarydata.com>
References: <1396605654-10108-1-git-send-email-jlayton@redhat.com>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 4, 2014, at 6:00, Jeff Layton <jlayton@redhat.com> wrote:

> There is no guarantee that the strings in the nfs_cache_array will be
> NULL-terminated. In the event that we end up hitting a readdir loop, we
> need to ensure that we pass the warning message a properly-terminated
> string.
> 
> Reported-by: Lachlan McIlroy <lmcilroy@redhat.com>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> fs/nfs/dir.c | 7 ++++---
> 1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 5c0b6ecc3a88..4689b125f9fe 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -304,12 +304,13 @@ int nfs_readdir_search_for_cookie(struct nfs_cache_array *array, nfs_readdir_des
> 				if (ctx->duped > 0
> 				    && ctx->dup_cookie == *desc->dir_cookie) {
> 					if (printk_ratelimit()) {
> +						char *name = kstrndup(array->array[i].string.name, array->array[i].string.len, GFP_KERNEL);
> +
> 						pr_notice("NFS: directory %pD2 contains a readdir loop."
> 								"Please contact your server vendor.  "
> 								"The file: %s has duplicate cookie %llu\n",
> -								desc->file,
> -								array->array[i].string.name,
> -								*desc->dir_cookie);
> +								desc->file, name, *desc->dir_cookie);
> +						kfree(name);
> 					}

Umm… Any reason why we couldn’t just use ‘%.*s’ ?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

