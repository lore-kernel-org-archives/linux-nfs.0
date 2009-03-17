From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] nfsv3: convert xattrs to generic xattr API
Date: Tue, 17 Mar 2009 03:47:42 -0400
Message-ID: <20090317074742.GB3331@infradead.org>
References: <alpine.LRH.2.00.0903101253190.22273@tundra.namei.org> <20090315073033.GA3008@infradead.org> <alpine.LRH.2.00.0903160942050.25038@tundra.namei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
	Trond.Myklebust@netapp.com
To: James Morris <jmorris@namei.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49651 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667AbZCQHrp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Mar 2009 03:47:45 -0400
In-Reply-To: <alpine.LRH.2.00.0903160942050.25038-CK9fWmtY32x9JUWOpEiw7w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 16, 2009 at 09:52:43AM +1100, James Morris wrote:
> I think it's clearer and cleaner to convert all of the ops over to the 
> generic API, rather than, say, leaving in #ifdefs and similar code just 
> for listxattr.
> 
> Also, this is part of preparation for adding other xattr handlers to the 
> NFS client code.  The current xattr functions assume that ACLs are the 
> only types attributes being managed, and the generic handler code for 
> listxattr is necessary to manage others.
> 
> If it's not acceptable as-is, I'll just batch it up with the rest of the 
> changes later.

Honestly I think the "generic" listxattr implementation doesn't buy
us anything as it just calls all handlers in a loop.  But I'm not going
to NACK the patch for that, I have some greater plans in that area, it
just means touching one more place once the day comes.  And the work
to deal with list is more then offset by having get/set use the generic
helpers :)

