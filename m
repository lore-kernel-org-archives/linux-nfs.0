From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 0/4] nfs-utils gssd
Date: Thu, 01 May 2008 09:34:55 -0400
Message-ID: <20080501133455.28884.4768.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:41341 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751009AbYEANe4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 1 May 2008 09:34:56 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,
These have all been sent before, with various levels of formality,
but haven't made it into git yet.

1) adds code to gssd to read a possible alternate port number
from the info file.

2) adds the "other" DES encryption types to the default list that
can currently be negotiated.

3) adds a utility function to retrieve the current logging
verbosity.  (Used by the fourth patch to determine whether
it should print certain error messages.)

4) allows the administrator to specify multiple directories
where gssd can look for credentials caches.

