Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:45370 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab1LACrh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Nov 2011 21:47:37 -0500
Date: Thu, 1 Dec 2011 02:47:35 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: NeilBrown <neilb@suse.de>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Rename dir on server can cause client to get ESTALE - this time
 with PATCH
Message-ID: <20111201024735.GZ2203@ZenIV.linux.org.uk>
References: <20111114131929.7b341444@notabene.brown>
 <20111201124922.22e7d72f@notabene.brown>
 <20111201021251.GY2203@ZenIV.linux.org.uk>
 <1322706258.2646.6.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1322706258.2646.6.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 30, 2011 at 09:24:18PM -0500, Trond Myklebust wrote:

> > As far as I can tell, the idea of open done in ->d_revalidate() is
> > unsalvagable.  It's simply the wrong place for that.  Note that NFS
> > is the only filesystem trying to do atomic open stuff in its ->d_revalidate()
> > and it's not succeeding.
> 
> Not doing an open there is prohibitively expensive, though: you are
> likely to see your cached inode flushed down the toilet if you just drop
> the dentry...

Wrong.  All you really need is to have that attempt to issue OPEN shifted
into ->open() itself.  The only interesting part is that we might need
to drop the original dentry and use a new one for ->f_path.dentry.

Don't drop that dentry; after the case in ->d_revalidate() that would have
attempted that OPEN you would either cross into covering vfsmount (in which
case dentry should be left alone as you are doing now) or issue ->open().
If it's really not valid (i.e. if OPEN yields a different inode), we can
deal with that in ->open() just fine.  The *only* subtle part is how to
deal with "it's a symlink, go away" from the server.  Which will require
changes in do_last().  I have that stuff; it'll need debugging serious
review once posted.  Which I'm going to do over weekend.
