Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55245 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081Ab3LMOMp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Dec 2013 09:12:45 -0500
Date: Fri, 13 Dec 2013 06:12:43 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd4: ignore nfsv4.1 lockowners in
 nfsd4_release_lockowner
Message-ID: <20131213141243.GA20399@infradead.org>
References: <52AADAF6.40700@primarydata.com>
 <1386929026-12627-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1386929026-12627-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  	list_for_each_entry(sop, &nn->ownerstr_hashtbl[hashval], so_strhash) {
>  		if (sop->so_is_open_owner)
>  			continue;
> +		if (sop->so_client->cl_minorversion)
> +			continue;
>  		if (!same_owner_str(sop, owner, clid))
>  			continue;
>  		list_for_each_entry(stp, &sop->so_stateids,

This needs at least a good comment as it's not very obvious from
glancing over the code.  That being said is same_owner_str so much
overhead that it's really worth it?

