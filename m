Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:41311 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757519Ab2INIZ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 04:25:28 -0400
Subject: [PATCH 0/2] nfsd: backport fixes for 3.5 kernel
To: stable@vger.kernel.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, bfields@redhat.com, viro@zeniv.linux.org.uk,
        jbottomley@parallels.com
Date: Fri, 14 Sep 2012 12:25:17 +0400
Message-ID: <20120914082201.14353.83847.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello.
These two patches fixes existent NULL pointer dereference problem in 3.5.3
kernel in case of some error occured during NFSd service start.

Upstream commits:
19f7e2ca44dfc3c1b3f499fc46801f98d403500f 
57c8b13e3cd0f94944c9691ce7f58e5fcef8a12d


The following series implements...

---

Stanislav Kinsbursky (2):
      NFSd: introduce nfsd_destroy() helper
      NFSd: set nfsd_serv to NULL after service destruction


 fs/nfsd/nfsctl.c |    8 ++------
 fs/nfsd/nfsd.h   |   11 +++++++++++
 fs/nfsd/nfssvc.c |   24 ++++++++----------------
 3 files changed, 21 insertions(+), 22 deletions(-)

