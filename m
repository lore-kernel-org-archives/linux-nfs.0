Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39952 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751224AbaDRMN4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 08:13:56 -0400
Date: Fri, 18 Apr 2014 08:13:53 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Clear cached acl after setting a zero-length
 default posix acl:
Message-ID: <20140418121353.GC18612@fieldses.org>
References: <534FCD13.303@gmail.com>
 <20140417143634.GA20857@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140417143634.GA20857@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 17, 2014 at 07:36:34AM -0700, Christoph Hellwig wrote:
> On Thu, Apr 17, 2014 at 08:46:11PM +0800, Kinglong Mee wrote:
> > After setting ACL for directory, I got two problems that caused
> > by the cached zero-length default posix acl.
> > 
> > This patch just clears the cached zero-length default posix acl
> > after setting.
> > 
> > First problem:
> > # nfs4_setfacl -s A::OWNER@:RWX /mnt/123/; touch /mnt/123/test
> > ............ hang ...........
> 
> Nfsd must not call forget_cached_acl, that's the filesystems job.
> I think the right fix is to make sure nfsd4_set_nfs4_acl calls ->set_acl
> with a NULL ACL structure if there are no entries.
> 
> Btw, it would be really good if we kept tests like this as a regression
> test suite.  Is there one for NFS already?  If not we could add
> nfs-specific tests to xfstests as well.

I'd recommend pynfs for something like this.

(It talks NFSv4 directly to the server, so won't depend on client
acl-caching behavior, etc.)

--b.
