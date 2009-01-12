From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] NFSD: cleanup for nfs3proc.c
Date: Mon, 12 Jan 2009 03:03:25 -0500
Message-ID: <20090112080325.GA418@infradead.org>
References: <496a44f7.05636e0a.69b8.6278@mx.google.com> <20090112011231.GA31971@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Qinghuang Feng <qhfeng.kernel@gmail.com>,
	linux-kernel@vger.kernel.org, neilb@suse.de,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50821 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbZALID1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Jan 2009 03:03:27 -0500
In-Reply-To: <20090112011231.GA31971@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 11, 2009 at 08:12:31PM -0500, J. Bruce Fields wrote:
> On Mon, Jan 12, 2009 at 03:13:53AM +0800, Qinghuang Feng wrote:
> > MSDOS_SUPER_MAGIC is defined in <linux/magic.h>,
> > so use MSDOS_SUPER_MAGIC directly.
> 
> Thanks.  But does anyone know if there's any better way to figure out
> whether a filesystem supports links and symlinks than by checking
> s_magic == MSDOS_SUPER_MAGIC??

Or case insenstivit or..

If we had a working pathconf syscall and inode operation that'd be
easy..

