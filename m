Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38758 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751577AbeD3EcM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Apr 2018 00:32:12 -0400
From: NeilBrown <neilb@suse.com>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 30 Apr 2018 14:31:30 +1000
Subject: [PATCH 2/4] NFS: use cond_resched() when restarting walk of
 delegation list.
Cc: linux-nfs@vger.kernel.org, Lai Jiangshan <jiangshanlai@gmail.com>,
        Josh Triplett <josh@joshtriplett.org>,
        Steven Rostedt <rostedt@goodmis.org>,
        linux-kernel@vger.kernel.org
Message-ID: <152506269057.7246.14981035798693301405.stgit@noble>
In-Reply-To: <152506256513.7246.13171564155614823841.stgit@noble>
References: <152506256513.7246.13171564155614823841.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In three places we walk the list of delegations for an nfs_client
until an interesting one is found, then we act of that delegation
and restart the walk.

New delegations are added to the end of a list and the interesting
delegations are usually old, so in many case we won't repeat
a long walk over and over again, but it is possible - particularly if
the first server in the list has a large number of uninteresting
delegations.

In each cache the work done on interesting delegations will often
complete without sleeping, so this could loop many times without
giving up the CPU.

So add a cond_resched() at an appropriate point to avoid hogging the
CPU for too long.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 fs/nfs/delegation.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index af32365894c8..76ab1374f589 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -508,6 +508,7 @@ int nfs_client_return_marked_delegations(struct nfs_client *clp)
 			err = nfs_end_delegation_return(inode, delegation, 0);
 			iput(inode);
 			nfs_sb_deactive(server->super);
+			cond_resched();
 			if (!err)
 				goto restart;
 			set_bit(NFS4CLNT_DELEGRETURN, &clp->cl_state);
@@ -904,6 +905,7 @@ void nfs_delegation_reap_unclaimed(struct nfs_client *clp)
 			}
 			iput(inode);
 			nfs_sb_deactive(server->super);
+			cond_resched();
 			goto restart;
 		}
 	}
@@ -1020,6 +1022,7 @@ void nfs_reap_expired_delegations(struct nfs_client *clp)
 			}
 			iput(inode);
 			nfs_sb_deactive(server->super);
+			cond_resched();
 			goto restart;
 		}
 	}


