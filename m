Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:57468 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108AbaDPQho (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Apr 2014 12:37:44 -0400
Date: Wed, 16 Apr 2014 17:37:41 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 17/19] VFS: set PF_FSTRANS while namespace_sem is held.
Message-ID: <20140416163741.GY18016@ZenIV.linux.org.uk>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040337.10604.86740.stgit@notabene.brown>
 <20140416044618.GX18016@ZenIV.linux.org.uk>
 <20140416155230.4d02e4b9@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140416155230.4d02e4b9@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 16, 2014 at 03:52:30PM +1000, NeilBrown wrote:

> So something like this?  I put that in to my testing instead.

Something like this, yes...  And TBH I would prefer the same approach
elsewhere - this kind of hidden state makes it hard to do any kind of
analysis.

Put it that way - the simplest situation is when the allocation flags
depend only on the call site.  Next one is when it's a function of
call chain - somewhat harder to review.  And the worst is when it's
a function of previous history of execution - not just the call chain,
but the things that had been called (and returned) prior to that one.

How many of those locations need to be of the third kind?  All fs/namespace.c
ones are of the first one...
