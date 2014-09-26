Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:48330 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755848AbaIZXIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2014 19:08:05 -0400
Date: Sat, 27 Sep 2014 00:08:01 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: kernel BUG in fs/dcache.c running nfs
Message-ID: <20140926230801.GR7996@ZenIV.linux.org.uk>
References: <20140908144525.GB19811@infradead.org>
 <20140909105918.59477ee3@tlielax.poochiereds.net>
 <20140909154211.GA6614@infradead.org>
 <20140909121244.610f297d@tlielax.poochiereds.net>
 <20140909121546.3981121b@tlielax.poochiereds.net>
 <20140909135006.2b956f47@tlielax.poochiereds.net>
 <20140910135739.2b897d94@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140910135739.2b897d94@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 01:57:39PM +1000, NeilBrown wrote:

> The d_drop();d_add(); pattern is used a number of times in NFS, but what I
> didn't notice before is that it is only used if ->d_inode is NULL.

And the point of that "pattern" would be...?  If dentry is already negative
and hashed, it does nothing whatsoever.  If it is negative and unhashed,
d_drop() is a no-op, obviously.  And if it's positive, we get a nice
shiny oops.

Where are we doing anything of that sort, anyway?  I see a bloody odd
instance in nfs_atomic_open() and that's it.  Note that nfs_instantiate()
is different (and not necessary nice - that d_drop() in case when this
sucker is called from mkdir() is asking for races with mount()).  How
do we get a positive hashed dentry there, anyway?
