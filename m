Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37552 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab0KUKq2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Nov 2010 05:46:28 -0500
Date: Sun, 21 Nov 2010 05:46:24 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Moazam Raja <moazam@gmail.com>,
        linux-nfs@vger.kernel.org
Subject: Re: O_DIRECT, O_SYNC, or fsync() on NFS mounts?
Message-ID: <20101121104624.GA13874@infradead.org>
References: <AANLkTinX=Obq5LFGQzHYGgG_4s7N34faagsZZy09NwE9@mail.gmail.com>
 <1290194699.3135.49.camel@heimdal.trondhjem.org>
 <20101119200421.GA3143@fieldses.org>
 <1290201995.3135.63.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290201995.3135.63.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Nov 19, 2010 at 04:26:35PM -0500, Trond Myklebust wrote:
> If the application requests O_DIRECT/O_SYNC or calls fsync(), we are
> required by POSIX to ensure the data is safe on disk. The presence of an
> NFS delegation does not change that requirement.

That's not quite correct.  O_DIRECT for one is not actually specific in
Posix at all, and the documented Linux semantics only say that the
pagecache should not be used (even if it sometimes is with various
filesystems).  There is not guarantee that data actually is on disk or
reachable, for that you need to add the O_SYNC/O_DYSNC flag in addition
or use fsync/fdatasync.
	
