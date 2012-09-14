Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:11897 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752705Ab2INOcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Sep 2012 10:32:53 -0400
Subject: [PATCH 0/3] lockd: use per-net refrence-counted NSM clients
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, devel@openvz.org,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Fri, 14 Sep 2012 18:25:47 +0400
Message-ID: <20120914140811.10835.81465.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a bug fix for https://bugzilla.redhat.com/show_bug.cgi?id=830862.

The problem is that with NFSv4 mount in container (with separated mount
namesapce) and active lock on it, dying child reaped of this container will
try to umount NFS and doing this will try to create RPC client to send
unmonitor request to statd.
But creation of RCP client requires valid current->nsproxy (for operation with
utsname()) and during umount on child reaper exit it's equal to zero.

Proposed solution is to introduce refrence-counter per-net NSM client, which
is created on fist monitor call and destroyed after the lst monitor call.

The following series implements...

---

Stanislav Kinsbursky (3):
      lockd: use rpc client's cl_nodename for id encoding
      lockd: per-net NSM client creation and destruction helpers introduced
      lockd: create and use per-net NSM RPC clients on MON/UNMON requests


 fs/lockd/mon.c   |   91 +++++++++++++++++++++++++++++++++++++++++++-----------
 fs/lockd/netns.h |    4 ++
 fs/lockd/svc.c   |    1 +
 3 files changed, 77 insertions(+), 19 deletions(-)


