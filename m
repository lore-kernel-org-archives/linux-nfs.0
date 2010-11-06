From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/2] locks: let the caller free file_lock on ->setlease
 failure
Date: Sat, 6 Nov 2010 15:03:58 -0400
Message-ID: <20101106190358.GB15850@infradead.org>
References: <20101027133924.GB6328@fieldses.org>
 <201010271546.09036.arnd@arndb.de>
 <20101027145538.GC6328@fieldses.org>
 <20101027145929.GA5788@infradead.org>
 <20101030212500.GE480@fieldses.org>
 <20101031123419.GA4491@infradead.org>
 <20101031123510.GA4520@infradead.org>
 <20101103204147.GA6777@fieldses.org>
 <20101104014024.GA22498@fieldses.org>
 <20101104014128.GB22498@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Bryan Schumaker <bjschuma@netapp.com>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60099 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752612Ab0KFTEB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Nov 2010 15:04:01 -0400
In-Reply-To: <20101104014128.GB22498@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> A minor oversight from f7347ce4ee7c65415f84be915c018473e7076f31,
> "fasync: re-organize fasync entry insertion to allow it under a
> spinlock": this cleanup-on-error was only needed to handle -ENOMEM.  Now
> that we're preallocating it's unneeded.

Looks good to me, too.

