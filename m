Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D897C282CC
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 10:01:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1767720844
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 10:01:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727099AbfBEKBn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 05:01:43 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:32953 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725954AbfBEKBn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 05:01:43 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id 35A20201353433;
        Tue,  5 Feb 2019 11:01:41 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     stable@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org, bfields@fieldses.org
Subject: [PATCH 4.14 0/2] Two nfsd4 fixes for 4.14 longterm
Date:   Tue,  5 Feb 2019 11:01:39 +0100
Message-Id: <20190205100141.25304-1-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Please include the upstream patches

    *  commit 085def3ade52 ("nfsd4: fix cached replies to solo SEQUENCE
compounds")
    *  commit 53da6a53e1d4 ("nfsd4: catch some false session retries")

into longterm kernel 4.14.

Because these patches went upstream in 4.15, they are already
included in longterm 4.19 and stable.

A nfsd4 server failure, where the server sends unrelated replies
to client requests containing only SEQUENCE operations has been
experienced with kernel version 4.14.87 [1]. Because the client
retries endlessly, this completely breaks the nfs mount.

A backport of these patches has been suggested by the patch
author J. Bruce Fields. [1]

Only limited testing has been done (running a single server with
4.14.96 and these two patches for a week and generating some high
load on it). It can not be proven by testing, that the patches
really fix the experienced problem. However, as the patches are
part of upstream and stable kernels for over a year
they should be a save pick.

Backport note: Only line numbers updated.

[1] https://bugzilla.kernel.org/show_bug.cgi?id=202435

J. Bruce Fields (2):
  nfsd4: fix cached replies to solo SEQUENCE compounds
  nfsd4: catch some false session retries

 fs/nfsd/nfs4state.c | 57 ++++++++++++++++++++++++++++++++++++++++-----
 fs/nfsd/state.h     |  2 ++
 fs/nfsd/xdr4.h      | 13 +++++++++--
 3 files changed, 64 insertions(+), 8 deletions(-)

-- 
2.20.0

