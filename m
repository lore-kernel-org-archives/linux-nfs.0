Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60109 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056Ab0KFTEx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Nov 2010 15:04:53 -0400
Date: Sat, 6 Nov 2010 15:04:50 -0400
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Arnd Bergmann <arnd@arndb.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Bryan Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: nfsd changes for 2.6.37
Message-ID: <20101106190450.GC15850@infradead.org>
References: <20101026164549.GD19445@fieldses.org>
 <20101027083924.GA28129@infradead.org>
 <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
 <20101031123419.GA4491@infradead.org>
 <20101101150214.GA27029@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101101150214.GA27029@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Btw, the nfsd delegation code still has a few comments referring to the
BKL.  This should probably be cleaned up:

fs/nfsd/nfs4state.c: * Called from break_lease() with lock_kernel() held.
fs/nfsd/nfs4state.c:    /* only place dl_time is set. protected by lock_kernel*/
fs/nfsd/nfs4state.c: * Called by locks_free_lock() with lock_kernel() held.
fs/nfsd/nfs4state.c: * Called from setlease() with lock_kernel() held

