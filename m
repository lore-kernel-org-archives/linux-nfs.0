From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 04/33] NFS: Fix nfs_wb_page() to always exit with an error or a clean page
Date: Mon, 21 Apr 2008 14:53:46 -0400
Message-ID: <5A5AEA53-E5D2-4A26-A478-2C26A44B8FE7@oracle.com>
References: <20080419204047.14124.49490.stgit@c-69-242-210-120.hsd1.mi.comcast.net> <20080419204048.14124.46594.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:30714 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbYDUSzd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2008 14:55:33 -0400
In-Reply-To: <20080419204048.14124.46594.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On Apr 19, 2008, at 4:40 PM, Trond Myklebust wrote:
> It is possible for nfs_wb_page() to sometimes exit with 0 return  
> value, yet
> the page is left in a dirty state.
> For instance in the case where the server rebooted, and the COMMIT  
> request
> failed, then all the previously "clean" pages which were cached by the
> server, but were not guaranteed to have been writted out to disk,
> have to be redirtied and resent to the server.
> The fix is to have nfs_wb_page_priority() check that the page is clean
> before it exits...

We have somewhat similar logic in nfs_wb_page_cancel and  
__nfs_write_mapping.  How is it that these two are not affected by the  
"server reboot / commit failed" scenario?  Do they simply retry until  
the resent write succeeds?

> This fixes a condition that triggers the BUG_ON(PagePrivate(page)) in
> nfs_create_request() when we're in the nfs_readpage() path.

Seems like there's more at stake here than just triggering a BUG.

In the launder_page path, dirty data could be lost if nfs_wb_page  
returns zero, but hasn't successfully flushed the data to the server,  
right?

In the nfs_flush_incompatible path, you would lose write ordering at  
the least... couldn't that potentially result in data corruption?

I don't recall the test case that triggered the BUG.  Do we have a  
test that is run often (eg. fsx or fsx-odirect) that exercises this  
path?

> Also eliminate a redundant BUG_ON(!PageLocked(page)) while we're at  
> it. It
> turns out that clear_page_dirty_for_io() has the exact same test.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> fs/nfs/write.c |   23 ++++++++++++-----------
> 1 files changed, 12 insertions(+), 11 deletions(-)
>
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index ce40cad..997b42a 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1493,18 +1493,19 @@ static int nfs_wb_page_priority(struct inode  
> *inode, struct page *page,
> 	};
> 	int ret;
>
> -	BUG_ON(!PageLocked(page));
> -	if (clear_page_dirty_for_io(page)) {
> -		ret = nfs_writepage_locked(page, &wbc);
> +	do {
> +		if (clear_page_dirty_for_io(page)) {
> +			ret = nfs_writepage_locked(page, &wbc);
> +			if (ret < 0)
> +				goto out_error;
> +		} else if (!PagePrivate(page))
> +			break;
> +		ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
> 		if (ret < 0)
> -			goto out;
> -	}
> -	if (!PagePrivate(page))
> -		return 0;
> -	ret = nfs_sync_mapping_wait(page->mapping, &wbc, how);
> -	if (ret >= 0)
> -		return 0;
> -out:
> +			goto out_error;
> +	} while (PagePrivate(page));
> +	return 0;
> +out_error:
> 	__mark_inode_dirty(inode, I_DIRTY_PAGES);
> 	return ret;
> }
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



