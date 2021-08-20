Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61F08C4338F
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 14:53:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2FB4F6112E
	for <linux-nfs@archiver.kernel.org>; Fri, 20 Aug 2021 14:53:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240887AbhHTOy1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 20 Aug 2021 10:54:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:47240 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S240879AbhHTOy0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Aug 2021 10:54:26 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id C4EE661102
        for <linux-nfs@vger.kernel.org>; Fri, 20 Aug 2021 14:53:48 +0000 (UTC)
Subject: [PATCH v3 0/4] SunRPC fault injection
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 20 Aug 2021 10:53:48 -0400
Message-ID: <162947112222.3311.9483898011770198455.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The following series (re)implements SunRPC disconnect injection
using the kernel's generic fault injection infrastructure under
debugfs. It's partially a clean-up and partially a fresh
implementation of server-side disconnect injection, while also
enabling the straightforward addition of further types of fault
injection in the future.

Changes since v2:
- CONFIG options still not right, complexity now hidden in Kconfig

Changes since v1:
- Now builds properly with various combinations of CONFIG options

---

Chuck Lever (4):
      SUNRPC: Add a /sys/kernel/debug/fail_sunrpc/ directory
      SUNRPC: Move client-side disconnect injection
      SUNRPC: Server-side disconnect injection
      SUNRPC: Add documentation for the fail_sunrpc/ directory


 .../fault-injection/fault-injection.rst       | 18 +++++
 include/linux/sunrpc/xprt.h                   | 18 -----
 lib/Kconfig.debug                             |  7 ++
 net/sunrpc/debugfs.c                          | 73 +++++--------------
 net/sunrpc/fail.h                             | 25 +++++++
 net/sunrpc/svc.c                              |  8 ++
 net/sunrpc/xprt.c                             | 14 ++++
 7 files changed, 92 insertions(+), 71 deletions(-)
 create mode 100644 net/sunrpc/fail.h

--
Chuck Lever

