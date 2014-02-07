Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:1774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751898AbaBGPk1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 7 Feb 2014 10:40:27 -0500
Date: Fri, 7 Feb 2014 10:39:24 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com,
        jstancek@redhat.com, mgorman@suse.de, riel@redhat.com,
        linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
        linux-mm@kvack.org
Subject: Re: [PATCH] mm: fix page leak at nfs_symlink()
Message-ID: <20140207103924.25ec5baa@tlielax.poochiereds.net>
In-Reply-To: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
References: <f4b3dc07dfa55bf7931de36b03aa9ef7e3ff0490.1391785222.git.aquini@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri,  7 Feb 2014 13:19:54 -0200
Rafael Aquini <aquini@redhat.com> wrote:

> Changes committed by "a0b8cab3 mm: remove lru parameter from
> __pagevec_lru_add and remove parts of pagevec API" have introduced
> a call to add_to_page_cache_lru() which causes a leak in nfs_symlink() 
> as now the page gets an extra refcount that is not dropped.
> 
> Jan Stancek observed and reported the leak effect while running test8 from
> Connectathon Testsuite. After several iterations over the test case,
> which creates several symlinks on a NFS mountpoint, the test system was
> quickly getting into an out-of-memory scenario.
> 
> This patch fixes the page leak by dropping that extra refcount 
> add_to_page_cache_lru() is grabbing. 
> 
> Signed-off-by: Jan Stancek <jstancek@redhat.com>
> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
>  fs/nfs/dir.c | 5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index be38b57..4a48fe4 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1846,6 +1846,11 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
>  							GFP_KERNEL)) {
>  		SetPageUptodate(page);
>  		unlock_page(page);
> +		/*
> +		 * add_to_page_cache_lru() grabs an extra page refcount.
> +		 * Drop it here to avoid leaking this page later.
> +		 */
> +		page_cache_release(page);
>  	} else
>  		__free_page(page);
>  

Looks reasonable as an interim fix and should almost certainly go to
stable.

Longer term, I think it would be best from an API standpoint to fix
add_to_page_cache_lru not to take this extra reference (or to have it
drop it itself) and fix up the callers accordingly. That seems like a
trap for the unwary...

-- 
Jeff Layton <jlayton@redhat.com>
