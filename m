Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43653 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752497Ab1BURtl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Feb 2011 12:49:41 -0500
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/7] pnfs write functionality (wave 4)
Date: Mon, 21 Feb 2011 12:49:29 -0500
Message-Id: <1298310576-13523-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

These apply on top of Andy's most recent wave3 patches.

They can also be found at the branch wave4-submit-1 at
git://linux-nfs.org/~iisaman/linux-pnfs.git

These patches give write functionality to the pnfs file layout driver.
The primary limitation is that we have not yet modified the commit
code, so we can not yet handle COMMITs to the data server.  We get
around this for the moment by sending any WRITE to a data server which
does not have commit-to-mds set as a SYNCH write.  The next patchset will
address this limitation.

Fred

