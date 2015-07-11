Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34188 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbbGKMy3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jul 2015 08:54:29 -0400
Date: Sat, 11 Jul 2015 05:54:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 07/10 v7] sunrpc: Switch to using list_head instead
 single list
Message-ID: <20150711125426.GA16906@infradead.org>
References: <55A11010.6050005@gmail.com>
 <55A11112.8080502@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A11112.8080502@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	struct list_head *	hash_table;

For hash lists it might be useful to use a hlist_head structure, as that
avoids bloating the actual hash table while still allowing easy removal
of an entry.

> -	for (hp=head; *hp != NULL ; hp = &(*hp)->next) {
> -		struct cache_head *tmp = *hp;
> +	list_for_each_safe(pos, tpos, head) {
> +		tmp = list_entry(pos, struct cache_head, cache_list);

Please use the _entry iteration macros that consolidate these two.

