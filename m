From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATH 19/19] exportfs: remove old methods
Date: Thu, 30 Aug 2007 14:35:52 +0100
Message-ID: <20070830133552.GA4972@infradead.org>
References: <20070830131729.GT6834@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQkBe-0000hJ-Mc
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 06:35:54 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQkBh-0004hh-Vh
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 06:35:59 -0700
In-Reply-To: <20070830131729.GT6834@lst.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Aug 30, 2007 at 03:17:29PM +0200, Christoph Hellwig wrote:
> Now that all filesystems are converted remove support for the
> old methods.

hmm, git mail got the ordering wrong, this one should be applied
before the one to mark the method tables const to get a bisectable
tree.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
