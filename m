Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755196Ab3GBAkC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Jul 2013 20:40:02 -0400
Date: Mon, 1 Jul 2013 20:39:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, Bodo Stroesser <bstroesser@ts.fujitsu.com>
Subject: Re: [PATCH 0/5] Fix assorted races in the sunrpc cache.
Message-ID: <20130702003958.GG19945@fieldses.org>
References: <20130613025132.31861.97407.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130613025132.31861.97407.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 13, 2013 at 12:53:42PM +1000, NeilBrown wrote:
> There are a few races possible in the sunrpc cache which can result in
> messages being dropped or memory not being freed.
> 
> These patches have been tested extensively and appear to remove all
> dropped-message errors and memory leaks.

OK, thanks very much to both of you for keeping at these.  Applied to

	git://linux-nfs.org/~bfields/linux.git for-3.11

Some trivial fixup to the second patch was needed due to
b6040f9706c4c81cc50b50855ed70840f022bebb "sunrpc: the cache_detail in
cache_is_valid is unused any more" (but you might want to double-check
to make sure I didn't typo something).

--b.
