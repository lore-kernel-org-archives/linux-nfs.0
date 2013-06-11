Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:29561 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752039Ab3FKOjX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 10:39:23 -0400
Subject: [PATCH v2 0/4] SUNRPC: PipeFS races fixes
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, linux-kernel@vger.kernel.org,
        jlayton@redhat.com
Date: Tue, 11 Jun 2013 18:39:02 +0400
Message-ID: <20130611143725.16046.17279.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This series fixes races between PipeFS mount/umount notification calls and
SUNRPC clients creation and destruction.

https://bugzilla.redhat.com/show_bug.cgi?id=924649

v2: Fixed few silly locking bugs.

The following series implements...

---

Stanislav Kinsbursky (4):
      SUNRPC: split client creation routine into setup and registration
      SUNRPC: fix races on PipeFS MOUNT notifications
      SUNRPC: fix races on PipeFS UMOUNT notifications
      SUNRPC: PipeFS MOUNT notification optimization for dying clients


 net/sunrpc/clnt.c     |   71 ++++++++++++++++++++++++++++++-------------------
 net/sunrpc/rpc_pipe.c |    5 +++
 2 files changed, 48 insertions(+), 28 deletions(-)

