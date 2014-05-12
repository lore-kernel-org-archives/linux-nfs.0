Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47462 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbaELFdR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 01:33:17 -0400
Date: Sun, 11 May 2014 22:33:17 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 39/43] nfsd4: really fix nfs4err_resource in 4.1 case
Message-ID: <20140512053317.GA29134@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-40-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399841568-19716-40-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +	if (op->status == nfserr_resource && nfsd4_has_session(&resp->cstate)) {
> +		struct nfsd4_slot *slot = resp->cstate.slot;
> +
> +		if (slot->sl_flags & NFSD4_SLOT_CACHETHIS)
> +			op->status = nfserr_rep_too_big_to_cache;
> +		else
> +			op->status = nfserr_rep_too_big;

There is a closing brace missing here, which breaks the compile for me.

