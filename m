Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2A58C4332F
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Nov 2021 13:49:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C9EE261ABD
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Nov 2021 13:49:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236861AbhKPNwh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Nov 2021 08:52:37 -0500
Received: from us-smtp-delivery-124.mimecast.com ([170.10.129.124]:34812 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S236887AbhKPNwa (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Nov 2021 08:52:30 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1637070571;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=HmT/GAUJAsL01/J0gVeRWL4tXpFMY8na2Cvok1D2e8s=;
        b=Y8HMXv+ncfKercRtuJVE8bucFddnA7108AQOXvRkBdc3ubYCqqaY9K94CCV588NmmTN9++
        tX8D3xZElJ8JjkCPSaJYAO5MMt8HZYg0wihMxz7PUfWensR2peC/quqX+ychuzg/UhHzbe
        MVCs71HZvIiacq+1fYSH1ZSjxbMeUCs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-333-J36JOdg3O8qiNLTy0hPtcw-1; Tue, 16 Nov 2021 08:49:26 -0500
X-MC-Unique: J36JOdg3O8qiNLTy0hPtcw-1
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 10F3583DD17;
        Tue, 16 Nov 2021 13:49:25 +0000 (UTC)
Received: from bcodding.csb (ovpn-64-2.rdu2.redhat.com [10.10.64.2])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E2E2860C13;
        Tue, 16 Nov 2021 13:49:24 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id 6823710C30F0; Tue, 16 Nov 2021 08:49:24 -0500 (EST)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] COPY/CLONE pagecache invalidation
Date:   Tue, 16 Nov 2021 08:49:21 -0500
Message-Id: <cover.1637069577.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I found a small issue on the client with generic/432 when testing a server
that supports COPY/CLONE but doesn't have the open file descriptor cache.
Our current knfsd server's cache causes the server to not immediately
hand out a read delegation after a COPY/COMMIT, CLOSE, OPEN, so I suspect
our normal testing didn't catch this issue.

The client bug can be exposed by adding 5 second delays after xfs_io
commands in generic/432, which gives the server enough time to clean up the
cache and give the delegation.

Benjamin Coddington (3):
  NFSv42: Fix pagecache invalidation after COPY/CLONE
  NFSv42: Don't drop NFS_INO_INVALID_CHANGE if we hold a delegation
  NFS: Add a tracepoint to show the results of nfs_set_cache_invalid()

 fs/nfs/inode.c     | 5 ++++-
 fs/nfs/nfs42proc.c | 8 ++++++--
 fs/nfs/nfstrace.h  | 1 +
 3 files changed, 11 insertions(+), 3 deletions(-)

-- 
2.31.1

