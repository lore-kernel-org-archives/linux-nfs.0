Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB16AC43387
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:29:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 879DC21871
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:29:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727076AbeLRO31 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:29:27 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60884 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726546AbeLRO31 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:29:27 -0500
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 3AC8CC062EDC;
        Tue, 18 Dec 2018 14:29:27 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id C819B67164;
        Tue, 18 Dec 2018 14:29:26 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 49EA6207AD; Tue, 18 Dec 2018 09:29:26 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] un-deprecate nfsdcld
Date:   Tue, 18 Dec 2018 09:29:23 -0500
Message-Id: <20181218142926.27933-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 18 Dec 2018 14:29:27 +0000 (UTC)
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

v2:
- Addressed some coding style issues in nfsd4_create_clid_dir() &
  nfsd4_remove_clid_dir()

Scott Mayhew (3):
  nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed
    char array
  nfsd: un-deprecate nfsdcld
  nfsd: keep a tally of RECLAIM_COMPLETE operations when using nfsdcld

 fs/nfsd/netns.h               |   3 +
 fs/nfsd/nfs4recover.c         | 339 +++++++++++++++++++++++++++++++---
 fs/nfsd/nfs4state.c           |  82 ++++++--
 fs/nfsd/nfsctl.c              |   1 +
 fs/nfsd/state.h               |   8 +-
 include/uapi/linux/nfsd/cld.h |   1 +
 6 files changed, 389 insertions(+), 45 deletions(-)

-- 
2.17.1

