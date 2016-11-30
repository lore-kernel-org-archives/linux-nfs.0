Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56737 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754554AbcK3AzY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Nov 2016 19:55:24 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Wed, 30 Nov 2016 11:53:51 +1100
Subject: [PATCH 0/2] Revise handling of some mount errors.
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <148046718451.21092.10685567606499960786.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These two patches improve the error messages reported when mount.nfs
fails, and reduces the timeout for some errors which are unlikely to
persist.

---

NeilBrown (2):
      mount: don't hide temporary error code on timeout.
      mount: take history into account when assessing if an error is permanent.


 utils/mount/stropts.c |   31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

--
Signature

