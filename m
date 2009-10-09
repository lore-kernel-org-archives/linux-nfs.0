From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/4][RFC] NFSv3: implement extended attribute (XATTR)
	protocol
Date: Fri, 9 Oct 2009 19:14:00 -0400
Message-ID: <20091009231400.GA27963@infradead.org>
References: <alpine.LRH.2.00.0909200020360.31818@tundra.namei.org> <4ACB5FC0.7060307@redhat.com> <alpine.LRH.2.00.0910091132130.32154@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, Christoph Hellwig <hch@infradead.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	linux-fsdevel@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:56871 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760555AbZJIXOo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Oct 2009 19:14:44 -0400
In-Reply-To: <alpine.LRH.2.00.0910091132130.32154-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 09, 2009 at 11:39:21AM +1100, James Morris wrote:
> No, I just manually run a set of commands to verify basic behavior.
> 
> I gather LTP would be the best place to add tests for this?

xfstests has various patches for the xattr system calls, and it also
supports testing NFS in addition to various local filesystems.

