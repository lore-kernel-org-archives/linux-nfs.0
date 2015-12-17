Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56795 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755726AbbLQB6S (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 20:58:18 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 17 Dec 2015 12:56:34 +1100
Subject: [PATCH nfs-utils 0/2] fixes for protocol fallback on mount
Cc: linux-nfs@vger.kernel.org, Andreas Schwab <schwab@suse.com>,
        Takashi Iwai <tiwai@suse.com>
Message-ID: <20151217015524.19978.63114.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Two unrelated patches which both relate to protocol fallback
when mounting an NFS filesystem.

---

Andreas Schwab (1):
      Fix uninitialised variable usage in nfs_options2pmap

NeilBrown (1):
      Fix protocol minor version fall-back


 utils/mount/network.c |    5 ++++-
 utils/mount/stropts.c |    3 +++
 2 files changed, 7 insertions(+), 1 deletion(-)

--
Signature

