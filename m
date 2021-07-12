Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4C0CC07E99
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Jul 2021 14:52:27 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CBC146120A
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Jul 2021 14:52:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235263AbhGLOzI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Jul 2021 10:55:08 -0400
Received: from mail.kernel.org ([198.145.29.99]:38554 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S235209AbhGLOzF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Jul 2021 10:55:05 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id C33126120A
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2021 14:52:16 +0000 (UTC)
Subject: [PATCH RFC 0/7] XDR overhaul of NFS callback service
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 12 Jul 2021 10:52:16 -0400
Message-ID: <162610122257.2466.7452891285800059767.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The purpose of this series is to prepare for the optimization of
svc_process_common() to handle NFSD workloads more efficiently. In
other words, NFSD should be the lubricated common case, and callback
is the use case that takes exceptional paths.

Note: For the moment these are compile-tested only.

There are some additional clean-ups that will be possible once this
series is merged. See

https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/log/?h=nfsd-xdr-stream

for follow-on work.

---

Chuck Lever (7):
      SUNRPC: Add svc_rqst::rq_auth_stat
      SUNRPC: Set rq_auth_stat in the pg_authenticate() callout
      SUNRPC: Eliminate the RQ_AUTHERR flag
      NFS: Add a private local dispatcher for NFSv4 callback operations
      NFS: Remove unused callback void encoder and decoder
      NFS: Extract the xdr_init_encode/decode() calls from decode_compound
      NFS: Clean up the synopsis of callback process_op()


 fs/lockd/svc.c                    |  2 +
 fs/nfs/callback.c                 |  4 ++
 fs/nfs/callback_xdr.c             | 64 ++++++++++++++-----------------
 include/linux/sunrpc/svc.h        |  3 +-
 include/linux/sunrpc/svcauth.h    |  4 +-
 include/trace/events/sunrpc.h     |  9 ++---
 net/sunrpc/auth_gss/svcauth_gss.c | 47 ++++++++++++-----------
 net/sunrpc/svc.c                  | 39 ++++++-------------
 net/sunrpc/svcauth.c              |  8 ++--
 net/sunrpc/svcauth_unix.c         | 18 +++++----
 10 files changed, 92 insertions(+), 106 deletions(-)

--
Chuck Lever

