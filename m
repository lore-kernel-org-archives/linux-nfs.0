From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] nfsv3: convert xattrs to generic xattr API
Date: Mon, 16 Mar 2009 09:52:43 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0903160942050.25038@tundra.namei.org>
References: <alpine.LRH.2.00.0903101253190.22273@tundra.namei.org> <20090315073033.GA3008@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from tundra.namei.org ([65.99.196.166]:3233 "EHLO tundra.namei.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751859AbZCOWyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 15 Mar 2009 18:54:21 -0400
In-Reply-To: <20090315073033.GA3008@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 15 Mar 2009, Christoph Hellwig wrote:

> On Tue, Mar 10, 2009 at 01:11:50PM +1100, James Morris wrote:
> > Recently, I've been working on an implementation of an xattr protocol for 
> > NFSv3 (based on the Irix stuff).
> > 
> > The first logical step is to convert the existing xattr use to the generic 
> > xattr API code.  I figured this might be a useful change in its own right, 
> > per the patch below.  It seems to work ok with various hand-made tests of 
> > ACL operations and xattr syscalls.
> > 
> > Please review (and apply if it looks ok).
> 
> The get/srt bits looks good to me, bu I really don't see the point
> of using generic_listxattr.

I think it's clearer and cleaner to convert all of the ops over to the 
generic API, rather than, say, leaving in #ifdefs and similar code just 
for listxattr.

Also, this is part of preparation for adding other xattr handlers to the 
NFS client code.  The current xattr functions assume that ACLs are the 
only types attributes being managed, and the generic handler code for 
listxattr is necessary to manage others.

If it's not acceptable as-is, I'll just batch it up with the rest of the 
changes later.

- James
-- 
James Morris
<jmorris@namei.org>
