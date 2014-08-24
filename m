Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58717 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952AbaHXQKr (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 12:10:47 -0400
Date: Sun, 24 Aug 2014 09:10:46 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org, hch@infradead.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/10] locks/nfsd: internal lease API overhaul
Message-ID: <20140824161046.GI15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One more wishlist item in addition to the one mentioned in the patches:

 - add a return value to lm_break so that the lock manager can tell the
   core code "you can delete this lease right now".  That gets rid of
   the games with the timeout which require all kinds of race avoidance
   code in the users.

And a big one that doesn't seem easily addressable, but I'll drop it in
anyway:

 - calling ->lm_break without i_lock would make everyones life a heck
   lot easier..

