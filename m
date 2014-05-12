Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:47717 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaELFlP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 May 2014 01:41:15 -0400
Date: Sun, 11 May 2014 22:41:15 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 05/43] nfsd4: move nfsd4_operation to xdr4.h
Message-ID: <20140512054115.GF29134@infradead.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-6-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399841568-19716-6-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +struct nfsd4_operation *OPDESC(struct nfsd4_op *op)

I don't think OPDESC is a good name for a non-static function.


But looking at the whoile tree we only need the exposed information
in two simple places in nfs4xdr.c, so I'd suggest to export something
higher level instead, e.g. move nfsd4_max_reply into nfs4proc.c
and have a helper to check that the op doesn't modify anything and
warn if it does.

