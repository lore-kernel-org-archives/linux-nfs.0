Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32815 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754539AbdCJAiR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Mar 2017 19:38:17 -0500
From: NeilBrown <neilb@suse.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 10 Mar 2017 11:36:39 +1100
Subject: [PATCH 0/3] NFSD: Various fixes for the 'versions' file.
Cc: Trond Myklebust <trondmy@primarydata.com>, linux-nfs@vger.kernel.org
Message-ID: <148910618557.3032.8265198632788708076.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following is the patch to provide non-regressed (though slightly
clunky) behaviour to the 'versions' file, and to fix a couple of
minor related bugs I found while working on the code.

NeilBrown


---

NeilBrown (3):
      NFSD: further refinement of content of /proc/fs/nfsd/versions
      NFSD: fix nfsd_minorversion(.., NFSD_AVAIL)
      NFSD: fix nfsd_reset_versions for NFSv4.


 fs/nfsd/nfsctl.c |   43 +++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfssvc.c |   28 +++++++++++++---------------
 2 files changed, 46 insertions(+), 25 deletions(-)

--
Signature

