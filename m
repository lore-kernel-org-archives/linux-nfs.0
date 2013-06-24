Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:33491 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860Ab3FXHwv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Jun 2013 03:52:51 -0400
Subject: [PATCH v3 0/4] SUNRPC: PipeFS races fixes
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Mon, 24 Jun 2013 11:52:26 +0400
Message-ID: <20130624075131.17104.55399.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixes races between PipeFS mount/umount notification calls and
SUNRPC clients creation and destruction.

https://bugzilla.redhat.com/show_bug.cgi?id=924649

v3: fixes first (for easy backport to stable)

v2: Fixed few silly locking bugs.

The following series implements...

---

Stanislav Kinsbursky (4):
      SUNRPC: fix races on PipeFS MOUNT notifications
      SUNRPC: fix races on PipeFS UMOUNT notifications
      SUNRPC: split client creation routine into setup and registration
      SUNRPC: PipeFS MOUNT notification optimization for dying clients


 net/sunrpc/clnt.c     |   71 ++++++++++++++++++++++++++++++-------------------
 net/sunrpc/rpc_pipe.c |    5 +++
 2 files changed, 48 insertions(+), 28 deletions(-)

