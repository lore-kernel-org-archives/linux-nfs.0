Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34289 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbaGMLms (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 07:42:48 -0400
Date: Sun, 13 Jul 2014 04:42:44 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] nfsd: deny mode handling overhaul
Message-ID: <20140713114244.GA30809@infradead.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
 <20140710201448.GF26561@fieldses.org>
 <20140711074656.GA17661@infradead.org>
 <20140711143128.GA7305@fieldses.org>
 <20140711114227.2902a15e@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140711114227.2902a15e@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 11, 2014 at 11:42:27AM -0400, Jeff Layton wrote:
> Yes, thanks to both of you. The review and merging are much
> appreciated. Only 89 patches to go once these go in!

Might help if we can get them into slighly smaller reviewable chunks,
e.g. the next batch might be the stateid refcounting and everything
around it, deferring the various client and session related bits and the
fault injection changes for now.
