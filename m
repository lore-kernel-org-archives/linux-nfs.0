Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1543DC47096
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jun 2021 20:50:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id D57A361263
	for <linux-nfs@archiver.kernel.org>; Thu,  3 Jun 2021 20:50:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229617AbhFCUwU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 3 Jun 2021 16:52:20 -0400
Received: from mail.kernel.org ([198.145.29.99]:44442 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229576AbhFCUwT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 3 Jun 2021 16:52:19 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id B58A4613BF;
        Thu,  3 Jun 2021 20:50:34 +0000 (UTC)
Subject: [PATCH 00/29] XDR overhaul for server-side lockd
From:   Chuck Lever <chuck.lever@oracle.com>
To:     bfields@fieldses.org
Cc:     linux-nfs@vger.kernel.org
Date:   Thu, 03 Jun 2021 16:50:33 -0400
Message-ID: <162275337584.32691.3943139351165347555.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Continuing on with updating the server's XDR infrastructure to use
struct xdr_stream. This time is lockd's turn.

---

Chuck Lever (29):
      lockd: Remove stale comments
      lockd: Create a simplified .vs_dispatch method for NLM requests
      lockd: Common NLM XDR helpers
      lockd: Update the NLMv1 void argument decoder to use struct xdr_stream
      lockd: Update the NLMv1 TEST arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 LOCK arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 CANCEL arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 UNLOCK arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 nlm_res arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 SM_NOTIFY arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 SHARE arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 FREE_ALL arguments decoder to use struct xdr_stream
      lockd: Update the NLMv1 void results encoder to use struct xdr_stream
      lockd: Update the NLMv1 TEST results encoder to use struct xdr_stream
      lockd: Update the NLMv1 nlm_res results encoder to use struct xdr_stream
      lockd: Update the NLMv1 SHARE results encoder to use struct xdr_stream
      lockd: Update the NLMv4 void arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 TEST arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 LOCK arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 CANCEL arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 UNLOCK arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 nlm_res arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 SM_NOTIFY arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 SHARE arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 FREE_ALL arguments decoder to use struct xdr_stream
      lockd: Update the NLMv4 void results encoder to use struct xdr_stream
      lockd: Update the NLMv4 TEST results encoder to use struct xdr_stream
      lockd: Update the NLMv4 nlm_res results encoder to use struct xdr_stream
      lockd: Update the NLMv4 SHARE results encoder to use struct xdr_stream


 fs/lockd/svc.c             |  43 ++++
 fs/lockd/svcxdr.h          | 151 ++++++++++++++
 fs/lockd/xdr.c             | 402 ++++++++++++++++++------------------
 fs/lockd/xdr4.c            | 403 +++++++++++++++++++------------------
 include/linux/lockd/xdr.h  |   6 -
 include/linux/lockd/xdr4.h |   7 +-
 6 files changed, 610 insertions(+), 402 deletions(-)
 create mode 100644 fs/lockd/svcxdr.h

--
Chuck Lever

