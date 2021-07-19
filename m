Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AC98C07E95
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 15:02:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5545D6124C
	for <linux-nfs@archiver.kernel.org>; Mon, 19 Jul 2021 15:02:56 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S241627AbhGSOWO (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 19 Jul 2021 10:22:14 -0400
Received: from mail.kernel.org ([198.145.29.99]:55504 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S242796AbhGSOVC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Jul 2021 10:21:02 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 765946113B;
        Mon, 19 Jul 2021 15:01:36 +0000 (UTC)
Subject: [PATCH 0/3] NFSD: Clean up tracepoint string handling
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Cc:     rostedt@goodmis.org
Date:   Mon, 19 Jul 2021 11:01:35 -0400
Message-ID: <162670659736.60572.10597769067889138558.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

As discussed last week, here's what I've added to the for-next topic
branch at:

  git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git

See:

  https://lore.kernel.org/lkml/20210715215753.4a314e97@rorschach.local.home/T/#u

---

Chuck Lever (2):
      NFSD: Use new __string_len C macros for the nfs_dirent tracepoint
      NFSD: Use new __string_len C macros for nfsd_clid_class

Steven Rostedt (VMware) (1):
      tracing: Add trace_event helper macros __string_len() and __assign_str_len()


 fs/nfsd/trace.h                            | 17 ++++++--------
 include/trace/trace_events.h               | 22 ++++++++++++++++++
 samples/trace_events/trace-events-sample.h | 27 ++++++++++++++++++++++
 3 files changed, 56 insertions(+), 10 deletions(-)

--
Chuck Lever

