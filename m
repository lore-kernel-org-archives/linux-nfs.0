From: Andi Kleen <andi@firstfloor.org>
Subject: ->migratepage aops for nfs missing
Date: Tue, 4 Aug 2009 22:26:48 +0200
Message-ID: <20090804202648.GA12484@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:33288 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755004AbZHDU0w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Aug 2009 16:26:52 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond,

Any particular reason ->migratepage is not enabled for 
the nfs file aops?

Is it known to be unsafe to move NFS buffer pages at runtime?

I have a similar requirement for memory error handling.

Thanks,

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
