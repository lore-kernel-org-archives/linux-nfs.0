From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 0/2] send actual expiration for svcgssd gss contexts
Date: Thu, 04 Dec 2008 18:34:53 -0500
Message-ID: <20081204233341.5951.62162.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:40060 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750852AbYLDXey (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Dec 2008 18:34:54 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These patches allow svcgssd to supply the correct timeout value for the cache
entries associated with gss contexts.  The init cache values are changed from
"never" to 60 seconds.
