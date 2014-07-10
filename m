Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38637 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750778AbaGJKbC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 06:31:02 -0400
Date: Thu, 10 Jul 2014 03:31:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 015/100] nfsd: clean up reset_union_bmap_deny
Message-ID: <20140710103100.GA6935@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-16-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-16-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static void
> -reset_union_bmap_deny(unsigned long deny, struct nfs4_ol_stateid *stp)
> +reset_union_bmap_deny(u32 deny, struct nfs4_ol_stateid *stp)
>  {
>  	int i;
> -	for (i = 0; i < 4; i++) {
> +
> +	for (i = 1; i < 4; i++) {
>  		if ((i & deny) != i)
>  			clear_deny(i, stp);
>  	}


Couldn't this simply be written as:

	stp->st_deny_bmap &= ~deny;

and inlined into the caller?
