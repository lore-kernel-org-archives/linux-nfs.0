Return-Path: <SRS0=ZVvz=NR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7D12C46464
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 18:35:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9615320827
	for <linux-nfs@archiver.kernel.org>; Tue,  6 Nov 2018 18:35:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9615320827
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387848AbeKGEBp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 6 Nov 2018 23:01:45 -0500
Received: from mx1.redhat.com ([209.132.183.28]:60922 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387905AbeKGEBp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Nov 2018 23:01:45 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 129123082A31;
        Tue,  6 Nov 2018 18:35:12 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-123-119.rdu2.redhat.com [10.10.123.119])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E15541948B;
        Tue,  6 Nov 2018 18:35:11 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 6789F20BE2; Tue,  6 Nov 2018 13:35:11 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH RFC 0/4] un-deprecate nfsdcld
Date:   Tue,  6 Nov 2018 13:35:07 -0500
Message-Id: <20181106183511.17836-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 06 Nov 2018 18:35:12 +0000 (UTC)
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

Scott Mayhew (4):
  nfsd: fix a warning in __cld_pipe_upcall()
  nfsd: make nfs4_client_reclaim use an xdr_netobj instead of a fixed
    char array
  nfsd: un-deprecate nfsdcld
  nfsd: keep a tally of RECLAIM_COMPLETE operations when using nfsdcld

 fs/nfsd/netns.h               |   3 +
 fs/nfsd/nfs4recover.c         | 326 ++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c           |  82 +++++++--
 fs/nfsd/nfsctl.c              |   1 +
 fs/nfsd/state.h               |   8 +-
 include/uapi/linux/nfsd/cld.h |   1 +
 6 files changed, 372 insertions(+), 49 deletions(-)

-- 
2.17.1

