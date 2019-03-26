Return-Path: <SRS0=uQmJ=R5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D2C5C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 413242146F
	for <linux-nfs@archiver.kernel.org>; Tue, 26 Mar 2019 22:06:32 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731840AbfCZWGb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from mx1.redhat.com ([209.132.183.28]:43548 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730605AbfCZWGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Mar 2019 18:06:31 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id E36A37D7A2;
        Tue, 26 Mar 2019 22:06:30 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-122-200.rdu2.redhat.com [10.10.122.200])
        by smtp.corp.redhat.com (Postfix) with ESMTP id AD50319C7B;
        Tue, 26 Mar 2019 22:06:30 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 0AE9220C2E; Tue, 26 Mar 2019 18:06:30 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RFC v3 0/5] un-deprecate nfsdcld
Date:   Tue, 26 Mar 2019 18:06:25 -0400
Message-Id: <20190326220630.2911-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 26 Mar 2019 22:06:30 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When nfsdcld was released, it was quickly deprecated in favor of the
nfsdcltrack usermodehelper, so as to not require another running daemon.
That prevents NFSv4 clients from reclaiming locks from nfsd's running in
containers, since neither nfsdcltrack nor the legacy client tracking
code work in containers.  These patches un-deprecate the use of nfsdcld
for NFSv4 client tracking.

These patches are intended to go alongside some nfs-utils patches that
introduce an enhancement that allows nfsd to "slurp" up the client
records during client tracking initialization and store them internally
in hash table.  This enables nfsd to check whether an NFSv4 client is
allowed to reclaim without having to do an upcall to nfsdcld.  It also
allows nfsd to decide to end the v4 grace period early if the number of
RECLAIM_COMPLETE operations it has received from "known" clients is
equal to the number of entries in the hash table.  It also allows nfsd
to skip the v4 grace period altogether if it knows there are no clients
allowed to reclaim.

There is a fallback to allow nfsd to continue to work with older nfsdcld
daemons in the event that any are out in the wild (unlikely).
Everything should work fine except nfsd will not be able to exit the
grace period early or skip the grace period altogether.

v3:
- nfs4_state_start_net() now calls nfsd4_end_grace() instead of
  open-coding it
- Removed some unnecessary initializations of nr_reclaim_complete
- Removed dec_reclaim_complete() altogether.  If we're calling
  expire_client() as a result of receiving a DESTROY_CLIENTID or
  SETCLIENTID_CONFIRM then we wouldn't want to decrement the count.  And
  laundromat thread never expires clients due to loss of lease until the
  grace period is over (the laundromat gets rescheduled by 1 second as
  long as clients are reclaiming during that 1 second, for up to 2x the
  original grace period in total).  So dec_reclaim_complete() is
  unnecessary.
- Changed the preference order of client tracking methods.  The new
  order is 1) new nfdscld, 2) old nfsdcld, 3) nfsdcltrack, 4) legacy
  v4recovery directory.
- Added some special handling of legacy records sent by nfsdcld in the
  GraceStart downcalls.  nfsdcld will do a one-time "upgrade" from old
  tracking methods.  No changes are needed to accomodate nfsdcltrack
  records, but legacy records will be prefixed with the string "hash:", 
  and in the event that we do have legacy records in the
  reclaim_str_hashtbl we may need to do a second lookup using the hash
  in the event that a lookup using the client name string fails.

v2:
- Addressed some coding style issues in nfsd4_create_clid_dir() &
  nfsd4_remove_clid_dir()

Scott Mayhew (5):
  nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed
    char array
  nfsd: un-deprecate nfsdcld
  nfsd: keep a tally of RECLAIM_COMPLETE operations when using nfsdcld
  nfsd: re-order client tracking method selection
  nfsd: handle legacy client tracking records sent by nfsdcld

 fs/nfsd/netns.h               |   3 +
 fs/nfsd/nfs4recover.c         | 436 +++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c           |  63 +++--
 fs/nfsd/nfsctl.c              |   1 +
 fs/nfsd/state.h               |   8 +-
 include/uapi/linux/nfsd/cld.h |   1 +
 6 files changed, 457 insertions(+), 55 deletions(-)

-- 
2.17.2

