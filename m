Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38715 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750771AbeD3Eb6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Apr 2018 00:31:58 -0400
From: NeilBrown <neilb@suse.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 30 Apr 2018 14:31:30 +1000
Subject: [PATCH 0/4 V2] Avoid quadratic search when freeing delegations
Cc: linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        linux-kernel@vger.kernel.org
Message-ID: <152506256513.7246.13171564155614823841.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Following review from Mathieu (thanks) I've made some revisions
and split this into four patches.  The RCU change is now in patch 3
by itself.
I've also revised the description in the main (final) patch quite
a bit.

Thanks,
NeilBrown


---

NeilBrown (4):
      NFS: slight optimization for walking list for delegations
      NFS: use cond_resched() when restarting walk of delegation list.
      rculist: add list_for_each_entry_from_rcu()
      NFS: Avoid quadratic search when freeing delegations.


 fs/nfs/delegation.c     |   66 ++++++++++++++++++++++++++++++++++++++++++-----
 include/linux/rculist.h |   13 +++++++++
 2 files changed, 72 insertions(+), 7 deletions(-)

--
Signature

