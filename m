Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:55636 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750988AbdHQOc2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 17 Aug 2017 10:32:28 -0400
To: linux-nfs@vger.kernel.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Christoph Hellwig <hch@lst.de>,
        Colin Ian King <colin.king@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] lockd: Adjustments for some function implementations
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Message-ID: <e53b2d3a-239a-268c-5674-3c50b02c966f@users.sourceforge.net>
Date: Thu, 17 Aug 2017 16:32:10 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 17 Aug 2017 16:17:18 +0200

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Delete an error message for a failed memory allocation in reclaimer()
  Adjust 61 checks for null pointers

 fs/lockd/clnt4xdr.c | 12 ++++++------
 fs/lockd/clntlock.c | 16 ++++++----------
 fs/lockd/clntproc.c | 12 ++++++------
 fs/lockd/clntxdr.c  | 12 ++++++------
 fs/lockd/host.c     | 22 +++++++++++-----------
 fs/lockd/mon.c      | 16 ++++++++--------
 fs/lockd/svc.c      |  4 ++--
 fs/lockd/svc4proc.c |  6 +++---
 fs/lockd/svclock.c  | 14 +++++++-------
 fs/lockd/svcproc.c  |  6 +++---
 fs/lockd/svcshare.c |  2 +-
 fs/lockd/svcsubs.c  |  3 +--
 12 files changed, 60 insertions(+), 65 deletions(-)

-- 
2.14.0

