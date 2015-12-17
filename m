Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38077 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbbLQE2C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 23:28:02 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 17 Dec 2015 15:27:34 +1100
Subject: [PATCH nfs-utils 0/2] Fix problems caused by rpc.statd being
 unresponsive.
Cc: linux-nfs@vger.kernel.org
Message-ID: <20151217042613.7581.1566.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If rpc.statd is temporarily unresponsive (e.g. because DNS service is
slow) it can cause mount attempts to fail inappropriately or can cause
multiple rpc.statd processes to be running on the one machine.

These patches address those problems.

---

NeilBrown (2):
      mount.nfs: trust the exit status of "start_statd".
      start-statd: don't run multiple rpc.statds on the one host.


 utils/mount/network.c   |    6 +++++-
 utils/statd/start-statd |    8 ++++++++
 2 files changed, 13 insertions(+), 1 deletion(-)

--
Signature

