From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfsv3: convert xattrs to generic xattr API
Date: Sun, 15 Mar 2009 03:30:33 -0400
Message-ID: <20090315073033.GA3008@infradead.org>
References: <alpine.LRH.2.00.0903101253190.22273@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
	Christoph Hellwig <hch@infradead.org>
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:44414 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbZCOHag (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Mar 2009 03:30:36 -0400
In-Reply-To: <alpine.LRH.2.00.0903101253190.22273-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 10, 2009 at 01:11:50PM +1100, James Morris wrote:
> Recently, I've been working on an implementation of an xattr protocol for 
> NFSv3 (based on the Irix stuff).
> 
> The first logical step is to convert the existing xattr use to the generic 
> xattr API code.  I figured this might be a useful change in its own right, 
> per the patch below.  It seems to work ok with various hand-made tests of 
> ACL operations and xattr syscalls.
> 
> Please review (and apply if it looks ok).

The get/srt bits looks good to me, bu I really don't see the point
of using generic_listxattr.

