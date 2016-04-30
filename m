Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34706 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbcD3T3d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 30 Apr 2016 15:29:33 -0400
Date: Sat, 30 Apr 2016 20:29:31 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: parallel lookups on NFS
Message-ID: <20160430192931.GD25498@ZenIV.linux.org.uk>
References: <20160424023453.GK25498@ZenIV.linux.org.uk>
 <1461501975.5219.40.camel@poochiereds.net>
 <20160424191835.GL25498@ZenIV.linux.org.uk>
 <20160429075812.GY25498@ZenIV.linux.org.uk>
 <1462022142.10011.19.camel@poochiereds.net>
 <1462022576.10011.22.camel@poochiereds.net>
 <20160430142232.GA25498@ZenIV.linux.org.uk>
 <1462027414.10011.31.camel@poochiereds.net>
 <20160430185836.GC25498@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160430185836.GC25498@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Apr 30, 2016 at 07:58:36PM +0100, Al Viro wrote:

> FWIW, I could reproduce that (and I really wonder WTF is going on - looks
> like nfs_async_unlink_release() getting lost somehow), but not the memory
> corruption with the last commit...  What .config are you using?

OK, I do understand the deadlock.  nfs_unblock_sillyrename() doesn't issue
a wakeup.  If you have lookup/lookup colliding on nfs_block_sillyrename()
*and* no pending delayed unlinks in that directory, you are stuck.  Grr...
I'll see if the obvious fix helps and push it into the queue if it does.

It doesn't explain the memory corruptor, though.  Could you post your .config?
