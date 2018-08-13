Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2120.oracle.com ([156.151.31.85]:37970 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727799AbeHMLtb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2018 07:49:31 -0400
Date: Mon, 13 Aug 2018 12:08:01 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: kolga@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [bug report] NFS recover from destination server reboot for copies
Message-ID: <20180813090801.vowc2e3jeizkf6kx@kili.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Olga Kornievskaia,

The patch c41d9b5efd9d: "NFS recover from destination server reboot
for copies" from Jul 9, 2018, leads to the following static checker
warning:

	fs/nfs/nfs4state.c:1595 nfs4_reclaim_open_state()
	warn: 'state' was already freed.

fs/nfs/nfs4state.c
  1573                          continue;
  1574                  atomic_inc(&state->count);
  1575                  spin_unlock(&sp->so_lock);
  1576                  status = ops->recover_open(sp, state);
  1577                  if (status >= 0) {
  1578                          status = nfs4_reclaim_locks(state, ops);
  1579                          if (status >= 0) {
  1580                                  if (!test_bit(NFS_DELEGATED_STATE, &state->flags)) {
  1581                                          spin_lock(&state->state_lock);
  1582                                          list_for_each_entry(lock, &state->lock_states, ls_locks) {
  1583                                                  if (!test_bit(NFS_LOCK_INITIALIZED, &lock->ls_flags))
  1584                                                          pr_warn_ratelimited("NFS: "
  1585                                                                              "%s: Lock reclaim "
  1586                                                                              "failed!\n", __func__);
  1587                                          }
  1588                                          spin_unlock(&state->state_lock);
  1589                                  }
  1590                                  clear_bit(NFS_STATE_RECLAIM_NOGRACE,
  1591                                          &state->flags);
  1592                                  nfs4_put_open_state(state);
                                                            ^^^^^^
Potential free?

  1593                                  spin_lock(&sp->so_lock);
  1594  #ifdef CONFIG_NFS_V4_2
  1595                                  if (test_bit(NFS_CLNT_DST_SSC_COPY_STATE, &state->flags)) {
  1596                                          struct nfs4_copy_state *copy;
  1597  
  1598                                          spin_lock(&sp->so_server->nfs_client->cl_lock);
  1599                                          list_for_each_entry(copy, &sp->so_server->ss_copies, copies) {
  1600                                                  if (memcmp(&state->stateid.other, &copy->parent_state->stateid.other, NFS4_STATEID_SIZE))
                                                                    ^^^^^
So this one isn't really supposed to generate a warning but there were
a couple bugs in Smatch which meant that it does.  But looking at it,
I wasn't sure if maybe moving the nfs4_put_open_state() might be a good
idea.  Either way, I'm going to silence this warning in Smatch.

  1601                                                          continue;
  1602                                                  copy->flags = 1;
  1603                                                  complete(&copy->completion);
  1604                                                  break;
  1605                                          }
  1606                                          spin_unlock(&sp->so_server->nfs_client->cl_lock);
  1607                                  }
  1608  #endif /* CONFIG_NFS_V4_2 */
  1609                                  goto restart;
  1610                          }
  1611                  }

regards,
dan carpenter
