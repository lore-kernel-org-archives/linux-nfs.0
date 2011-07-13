Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10766 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754548Ab1GMOuu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2011 10:50:50 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH v5 0/2]  NFSD: add FREE_STATEID and TEST_STATEID operations
Date: Wed, 13 Jul 2011 10:50:46 -0400
Message-Id: <1310568648-11109-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

These patches add FREE_STATEID and TEST_STATEID to the NFS server.  I initially
tested them by hard coding calls both before and after the client completes a
CLOSE operation.  Eventually, I modified the client's state recovery code to
place these calls.  I would turn off networking on the client for two minutes
so it would expired on the server and force recovery once networking was
reenabled.

I later added in a fault injection framework on the server.  I would have the
client acquire a lock, tell the server to delete it, and then have the client
use TEST_STATEID and FREE_STATEID to recover the lock.

v2:
- FREE_STATEID
  - Free open, lock, and delegation state ids correctly
  - Use the check_for_locks() function to check for locks

  - TEST_STATEID
    - Remove openmode check
    - Sanity check on size of stateid list
    - Delay decoding stateid list until encoding the reply

v3:
  - FREE_STATEID
    - Open stateids and delegations are never freeable (return nfserr_locks_held)

  - TEST_STATEID
    - Remove unused arguments from a function call
    - Store and use the HAS_SESSION flag for validating stateids

v4:
  - FREE_STATEID
    - Remove unused argument from nfs4_free_lock_stateid()

  - TEST_STATEID
    - Remove double call to nfs4_validate_stateid()

v5:
  - FREE_STATEID
    - Acquire the state lock before using the state lists

  - TEST_STATEID
    - Acquire the state lock before using the state lists

- Bryan
