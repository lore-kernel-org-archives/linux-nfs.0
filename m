From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] exportfs: fix incorrect EACCES in reconnect_path()
Date: Fri, 2 May 2008 11:34:39 -0400
Message-ID: <20080502153439.GC7376@infradead.org>
References: <20080404102449.GA10209@janus> <20080407184346.GF3305@fieldses.org> <20080409133639.GA9588@lst.de> <18454.45086.254692.412079@notabene.brown> <20080429163554.GE20420@fieldses.org> <20080429174004.GA28719@janus> <20080430174736.GB20377@fieldses.org> <20080502151646.GA5515@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@lst.de>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:40417 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756809AbYEBPeo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 May 2008 11:34:44 -0400
In-Reply-To: <20080502151646.GA5515@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 02, 2008 at 05:16:46PM +0200, Frank van Maarseveen wrote:
> A privileged process on an NFS client which drops privileges after using
> them to change the current working directory, will experience incorrect
> EACCES after an NFS server reboot. This problem can also occur after
> memory pressure on the server, particularly when the client side is
> quiet for some time.
> 
> This patch removes the x-bit check during dentry tree reconstruction at
> the server by exportfs on behalf of nfsd.

I'm still against adding this crap, and even when I get overruled that
doesn't make the comments on lookup_one_noperm any less true, not does
it give you a permit to break the kerneldoc generation.

