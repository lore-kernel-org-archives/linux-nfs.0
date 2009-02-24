From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] EXPORT_SYMBOL(d_obtain_alias) rather than
 EXPORT_SYMBOL_GPL
Date: Tue, 24 Feb 2009 13:36:33 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0902241335010.3111@localhost.localdomain>
References: <499FA991.8080909@panasas.com> <20090221174046.GA27374@infradead.org> <20090221114015.7bb5c9d8.akpm@linux-foundation.org> <alpine.LFD.2.00.0902211146400.3111@localhost.localdomain> <49A4547E.90607@panasas.com>
 <20090224213222.GH28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Benny Halevy <bhalevy@panasas.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@infradead.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38687 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752931AbZBXVhD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Feb 2009 16:37:03 -0500
In-Reply-To: <20090224213222.GH28946@ZenIV.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On Tue, 24 Feb 2009, Al Viro wrote:
> 
> As an aside, EXPORT_SYMBOL_GPL() is obnoxious shite anyway.  If
> something is not a safe API, exporting it to default-quality 3rd-party
> code is bad and while GPL might be many things, it is not a magical
> "teach average programmer to find his arse without a map" pill.

Actually, I have had lawyers tell me it's actually a good idea, and shows 
"intent".  Intent may not matter for code in the sense that the code does 
what the code does regardless of what the programmer _intended_ it to do, 
but it does matter in legal terms.

So don't think of it in technical terms. It's not about good quality or 
about finding your arse without maps.

			Linus
