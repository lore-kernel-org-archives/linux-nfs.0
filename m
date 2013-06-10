Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:30811 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750930Ab3FJOkP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Jun 2013 10:40:15 -0400
Subject: [PATCH 0/3] SUNRPC: PipeFS races fixes
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Mon, 10 Jun 2013 18:39:53 +0400
Message-ID: <20130610143725.7498.72391.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixed races between PipeFS mount/umount notification calls and
SUNRPC clients creation and destruction.

https://bugzilla.redhat.com/show_bug.cgi?id=924649

The following series implements...

---

Stanislav Kinsbursky (3):
      SUNRPC: fix races on PipeFS UMOUNT notifications
      SUNRPC: fix races on PipeFS UMOUNT notifications
      SUNRPC: PipeFS MOUNT notification optimization for dying clients


 net/sunrpc/clnt.c     |   14 +++++++++-----
 net/sunrpc/rpc_pipe.c |    5 ++++-
 2 files changed, 13 insertions(+), 6 deletions(-)

