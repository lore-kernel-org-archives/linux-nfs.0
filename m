Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:50662 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbaGOPx6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 11:53:58 -0400
Date: Tue, 15 Jul 2014 08:53:56 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, linux-nfs@vger.kernel.org
Subject: Re: nfsd4_locku / nfs4_free_lock_stateid question
Message-ID: <20140715155356.GA24948@infradead.org>
References: <20140713110047.GA28727@infradead.org>
 <20140713080541.30ecbb51@tlielax.poochiereds.net>
 <20140713121919.GA6456@infradead.org>
 <20140715081334.654473fd@tlielax.poochiereds.net>
 <20140715145029.GI17956@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140715145029.GI17956@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 10:50:29AM -0400, J. Bruce Fields wrote:
> I'm not convinced it is.  But I understand that we're imposing a weird
> assumption on the lock interface: "if you're exportable, you should use
> the struct file we passed you only to get the inode".

We might as well stick with the old variant for now.  It's defintively
asking for trouble, but so far it worked..  I'll look into
refactoring the locking code so that it doesn't need the file instead.

