Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40133 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbaGMMTT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Jul 2014 08:19:19 -0400
Date: Sun, 13 Jul 2014 05:19:19 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: nfsd4_locku / nfs4_free_lock_stateid question
Message-ID: <20140713121919.GA6456@infradead.org>
References: <20140713110047.GA28727@infradead.org>
 <20140713080541.30ecbb51@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140713080541.30ecbb51@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 13, 2014 at 08:05:41AM -0400, Jeff Layton wrote:
> It is weird, but I don't think it really matters as the filp is only
> really used as a way to get to the inode -- it really doesn't matter
> which struct file we use there. find_any_file will both take a
> reference to and return the file, which is then eventually fput in
> filp_close, so there should be no refcount leak or anything.
> 
> The weirdness all comes from the vfs-layer file locking interfaces,
> many of which take a struct file argument when they really would be
> fine with a struct inode. Maybe one of these days we can get around to
> cleaning that up.

If filesystems get the file passed we should assume that they actually
use it.  In fact AFS does, but it's not NFS exportable at the moment,
and ceph does in a debug printk.  I'd be much happier to waste a pointer
in the lock stateid to avoid this inconsistant interface.  And it would
allow to kill find_any_fileas well..

