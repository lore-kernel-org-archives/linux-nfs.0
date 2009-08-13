From: Christoph Hellwig <hch@infradead.org>
Subject: NFS and NFSv4 lists?
Date: Thu, 13 Aug 2009 13:49:24 -0400
Message-ID: <20090813174923.GA15213@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51150 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbZHMRtd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Aug 2009 13:49:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there really a reason to keep a separate NFSv4 mailing list?  v4
support is part of the same nfs/nfsd modules and quite deeply
interwinded with the v2/v3 code.  It seems most posts to the NFSv4 list
get cross-posted to the regular nfs list anyway.


