Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.3]:59895 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754924AbeAMOCV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 13 Jan 2018 09:02:21 -0500
To: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 0/2] NFSD: Adjustments for six function implementations
Message-ID: <43df7d8b-f37e-91ca-9c8c-96e318adeb4f@users.sourceforge.net>
Date: Sat, 13 Jan 2018 15:02:14 +0100
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sat, 13 Jan 2018 15:00:15 +0100

Two update suggestions were taken into account
from static source code analysis.

Markus Elfring (2):
  Use seq_putc() in four functions
  Adjust four function calls together with a variable assignment

 fs/nfsd/export.c    | 19 ++++++++++++-------
 fs/nfsd/nfs4idmap.c |  4 ++--
 2 files changed, 14 insertions(+), 9 deletions(-)

-- 
2.15.1

