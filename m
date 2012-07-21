Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54995 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549Ab2GUQ5y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 Jul 2012 12:57:54 -0400
Date: Sat, 21 Jul 2012 11:57:41 -0500
From: Jonathan Nieder <jrnieder@gmail.com>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cachefs@redhat.com, linux-kernel@vger.kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 17/17] NFS: nfs_migrate_page() does not wait for FS-Cache
 to finish with a page
Message-ID: <20120721165741.GA9308@burratino>
References: <20120208211640.15607.58537.stgit@warthog.procyon.org.uk>
 <20120208211935.15607.16821.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120208211935.15607.16821.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

In February, David Howells wrote:

> nfs_migrate_page() does not wait for FS-Cache to finish with a page, probably
> leading to the following bad-page-state:
[...]
> nfs_migrate_page() calls nfs_fscache_release_page() which doesn't actually wait
> - even if __GFP_WAIT is set.  The reason that doesn't wait is that
> fscache_maybe_release_page() might deadlock the allocator as the work threads
> writing to the cache may all end up sleeping on memory allocation.
[...]
>  (1) Make nfs_migrate_page() wait.
>
>  (2) Make fscache_maybe_release_page() honour the __GFP_WAIT flag.
>
>  (3) Set a timeout around the wait.
>
>  (4) Make nfs_migrate_page() return an error if the page is still busy.
>
> For the moment, I'll select (2) and (4).
[...]
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1701,7 +1701,9 @@ int nfs_migrate_page(struct address_space *mapping, struct page *newpage,
>  	if (PagePrivate(page))
>  		return -EBUSY;
>  
> -	nfs_fscache_release_page(page, GFP_KERNEL);
> +	ret = -EBUSY;
> +	if (!nfs_fscache_release_page(page, GFP_KERNEL))
> +		goto out;
>  
>  	return migrate_page(mapping, newpage, page, mode);
>  }

Small thing, but it looks like this was forward-ported incorrectly.
Was this ever tested with CONFIG_MIGRATION enabled?

Hope that helps,
Jonathan
