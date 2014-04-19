Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60042 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaDSPEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Apr 2014 11:04:34 -0400
Date: Sat, 19 Apr 2014 08:04:23 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/70] NFSd lock scalability patches
Message-ID: <20140419150423.GG25682@infradead.org>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So after this series there are 5 callers of nfs4_lock_state() left,
and I can't see any coherent scheme of what it still protects, but this:

--- snip ---
/* Currently used for almost all code touching nfsv4 state: */
static DEFINE_MUTEX(client_mutex);
--- snip ---

is clearly wrong. I'd suggest you go all the way and remove it entirely.

