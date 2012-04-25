Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:20951 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073Ab2DYOWp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 10:22:45 -0400
Subject: [PATCH 0/6] Lockd: service start cleanup patch set
To: bfields@fieldses.org, Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Apr 2012 18:22:32 +0400
Message-ID: <20120425141934.22909.53047.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch set simplifies LockD start logic, makes code looks straight-forward
and clear.

The following series consists of:

---

Stanislav Kinsbursky (6):
      LockD: pass service to per-net up and down functions
      LockD: use existent per-net data function on service creation
      LockD: service creation function introduced
      LockD: move global usage counter manipulation from error path
      LockD: service start function introduced
      LockD: add debug message to start and stop functions


 fs/lockd/svc.c |  140 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 83 insertions(+), 57 deletions(-)

