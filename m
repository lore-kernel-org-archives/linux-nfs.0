From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] EXPORT_SYMBOL(d_obtain_alias) rather than
	EXPORT_SYMBOL_GPL
Date: Tue, 24 Feb 2009 21:32:22 +0000
Message-ID: <20090224213222.GH28946@ZenIV.linux.org.uk>
References: <499FA991.8080909@panasas.com> <20090221174046.GA27374@infradead.org> <20090221114015.7bb5c9d8.akpm@linux-foundation.org> <alpine.LFD.2.00.0902211146400.3111@localhost.localdomain> <49A4547E.90607@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:56495 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000AbZBXVcf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Feb 2009 16:32:35 -0500
In-Reply-To: <49A4547E.90607@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 24, 2009 at 12:11:42PM -0800, Benny Halevy wrote:
> Commit 4ea3ada2955e4519befa98ff55dd62d6dfbd1705
> declares d_obtain_alias() as EXPORT_SYMBOL_GPL
> where it's supposed to replace d_alloc_anon which
> was previously declared as EXPORT_SYMBOL and thus
> available to any loadable module.
> 
> This patch reverts that, as discussed below:

ACK.  d_obtain_alias() makes sense as a general-purpose interface, period.

	As an aside, EXPORT_SYMBOL_GPL() is obnoxious shite anyway.  If
something is not a safe API, exporting it to default-quality 3rd-party
code is bad and while GPL might be many things, it is not a magical
"teach average programmer to find his arse without a map" pill.

