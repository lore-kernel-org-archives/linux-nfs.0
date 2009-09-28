From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: nfsd patches for 2.6.33
Date: Mon, 28 Sep 2009 12:22:28 -0400
Message-ID: <1254154952-13083-1-git-send-email-bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48554 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752034AbZI1QWN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 12:22:13 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1MsIzg-0003RE-N7
	for linux-nfs@vger.kernel.org; Mon, 28 Sep 2009 12:22:32 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I intend to queue up the following patches (mainly small bugfixes and
cleanup) for 2.6.33.

I've started a for-2.6.33 branch at

	git://linux-nfs.org/~bfields/linux.git

Note: as of the last few kernel versions, I'm now committing to only
appending to these for-2.6.x branches (no rebasing or otherwise changing
history).  If there's a mistake, we'll add another patch on top to fix
it.

--b.
