Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58946 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751078AbaG0N6N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 09:58:13 -0400
Date: Sun, 27 Jul 2014 06:58:11 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 23/40] nfsd: Add reference counting to state owners
Message-ID: <20140727135811.GA5062@infradead.org>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
 <1405954972-28904-24-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405954972-28904-24-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +static void nfs4_put_stateowner(struct nfs4_stateowner *sop);

Just move the trivial implementation of this one towards the top of the
file?

> +	kfree(oo->oo_owner.so_owner.data);

Seems like freeing the owner data should stay in common code instead
of the instances.

> +	void (*so_free)(struct nfs4_stateowner *);

This probably should be an ops vector aswell.

