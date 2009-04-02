From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 0/2] nfs-utils: detect and log write errors
Date: Wed, 01 Apr 2009 20:05:46 -0400
Message-ID: <20090402000430.3234.81110.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:41254 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751782AbZDBAgA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2009 20:36:00 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Address at least one cause of a problem that has been reported
where it appears that a gss context was successfully created,
but the server returns GSS_S_NO_CONTEXT.

---

Kevin Coffman (2):
      svcgssd: check the return code from qword_eol() and log failures
      cacheio: return any original error from qword_eol


 support/nfs/cacheio.c     |   10 ++++++++--
 utils/gssd/svcgssd_proc.c |    4 ++++
 2 files changed, 12 insertions(+), 2 deletions(-)

