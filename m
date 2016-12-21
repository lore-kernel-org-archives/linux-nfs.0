Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:44854 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752273AbcLUATu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Dec 2016 19:19:50 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 21 Dec 2016 11:19:13 +1100
Subject: [PATCH 0/4] Assorted nfs-utils patches.
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Message-ID: <148227940052.31345.1974080582264239934.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First two relate to /etc/nfs.conf and nfsd.
Second to help make sure that nfs things don't cause
problem when they are started early because various
other services are available (most of that is already
fixed, these are just dribs and drabs).

At some stage I want to convert everything to use the same logging
infrastructure, but that doesn't need to happen before the pending
release.

Thanks,
NeilBrown


---

NeilBrown (4):
      nfsd: fix setting of minor version from config file.
      nfsd: Do not permit manipulation of NFSv4.0, e.g. "-N 4.0"
      nfs-server-generator: avoid using syslog
      mountd: delay reading etab until first request arrives.


 systemd/nfs-server-generator.c |    3 +++
 utils/mountd/mountd.c          |    2 --
 utils/nfsd/nfsd.c              |   20 ++++++++++++++++----
 utils/nfsd/nfsd.man            |   10 +++++-----
 4 files changed, 24 insertions(+), 11 deletions(-)

--
Signature

