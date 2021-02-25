Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D597BC433DB
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Feb 2021 02:44:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 8163864ECF
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Feb 2021 02:44:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236765AbhBYCny (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Feb 2021 21:43:54 -0500
Received: from mx2.suse.de ([195.135.220.15]:41930 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S234384AbhBYCnx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 24 Feb 2021 21:43:53 -0500
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.221.27])
        by mx2.suse.de (Postfix) with ESMTP id A73E5AD5C;
        Thu, 25 Feb 2021 02:43:10 +0000 (UTC)
From:   NeilBrown <neilb@suse.de>
To:     Steve Dickson <SteveD@RedHat.com>
Date:   Thu, 25 Feb 2021 13:42:47 +1100
Subject: [PATCH 0/5] nfs-utils: provide audit-logging of NFSv4 access
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Message-ID: <161422077024.28256.15543036625096419495.stgit@noble>
User-Agent: StGit/0.23
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When NFSv3 is used mountd provides logs of successful and failed mount
attempts which can be used for auditing.
When NFSv4 is used there are no such logs as NFSv4 does not have a
distinct "mount" request.

However mountd still knows about which filesysytems are being accessed
from which clients, and can actually provide more reliable logs than it
currently does, though they must be more verbose - with periodic "is
being accessed" message replacing a single "was mounted" message.

This series adds support for that logging, and adds some related
improvements to make the logs as useful as possible.

NeilBrown

---

NeilBrown (5):
      mountd: reject unknown client IP when !use_ipaddr.
      mountd: Don't proactively add export info when fh info is requested.
      mountd: add logging for authentication results for accesses.
      mountd: add --cache-use-ipaddr option to force use_ipaddr
      mountd: make default ttl settable by option


 support/export/auth.c      |  4 +++
 support/export/cache.c     | 32 +++++++++++------
 support/export/v4root.c    |  3 +-
 support/include/exportfs.h |  3 +-
 support/nfs/exports.c      |  4 ++-
 utils/mountd/mountd.c      | 29 +++++++++++++++-
 utils/mountd/mountd.man    | 70 ++++++++++++++++++++++++++++++++++++++
 7 files changed, 130 insertions(+), 15 deletions(-)

--
Signature

