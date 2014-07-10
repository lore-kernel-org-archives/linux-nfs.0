Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46762 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbaGJMpl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 08:45:41 -0400
Date: Thu, 10 Jul 2014 05:45:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 017/100] nfsd: make deny mode enforcement more
 efficient and close races in it
Message-ID: <20140710124540.GC30941@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-18-git-send-email-jlayton@primarydata.com>
 <20140710104927.GC6935@infradead.org>
 <20140710083628.4bec674e@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140710083628.4bec674e@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 08:36:28AM -0400, Jeff Layton wrote:
> Yeah, I considered that, I'll see if that will help things, but it
> might be best to leave that extra cleanup to a different patchset. This
> set is all about removing the client_mutex, not so much about cleaning
> up deny mode handling (even fixing that atomicity is a necessary step).

With the extensive changes to that area I would much prefer to get the
various bits rights before doing the locking instead of going back to
this later.

