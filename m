Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:53067 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754854Ab3IFRAq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Sep 2013 13:00:46 -0400
Date: Fri, 6 Sep 2013 10:00:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, Nick Piggin <npiggin@kernel.dk>
Subject: Re: [PATCH 1/3] dcache: use IS_ROOT to decide where dentry is hashed
Message-ID: <20130906170044.GA6460@infradead.org>
References: <1378482230-16312-1-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378482230-16312-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 06, 2013 at 11:43:48AM -0400, J. Bruce Fields wrote:
> diff --git a/fs/dcache.c b/fs/dcache.c
> index b949af8..934f02d 100644
> --- a/fs/dcache.c
> +++ b/fs/dcache.c
> @@ -393,7 +393,7 @@ static void __d_shrink(struct dentry *dentry)
>  {
>  	if (!d_unhashed(dentry)) {
>  		struct hlist_bl_head *b;
> -		if (unlikely(dentry->d_flags & DCACHE_DISCONNECTED))
> +		if (unlikely(IS_ROOT(dentry)))

I think this needs a comment about why the IS_ROOT check is fine,
destilled from your commit log.

Also while reviewing this I noticed that one of the two callers of
__d_shrink already has the d_unhashed check - it might make sense to
move it to the other caller as well if you touch this area anyway.
(as a separate patch).

