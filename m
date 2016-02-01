Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:46899 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055AbcBARfD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 12:35:03 -0500
Date: Mon, 1 Feb 2016 17:35:01 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cachefs@redhat.com
Subject: Re: [PATCH] CacheFiles: Provide read-and-reset release counters for
 cachefilesd
Message-ID: <20160201173501.GL17997@ZenIV.linux.org.uk>
References: <20160201164304.9867.40456.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160201164304.9867.40456.stgit@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 01, 2016 at 04:43:04PM +0000, David Howells wrote:
> Provide read-and-reset objects- and blocks-released counters for cachefilesd
> to use to work out whether there's anything new that can be culled.
> 
> One of the problems cachefilesd has is that if all the objects in the cache
> are pinned by inodes lying dormant in the kernel inode cache, there isn't
> anything for it to cull.  In such a case, it just spins around walking the
> filesystem tree and scanning for something to cull.  This eats up a lot of
> CPU time.

Applied.
