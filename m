Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f47.google.com ([209.85.214.47]:37263 "EHLO
        mail-it0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752619AbcH1WZD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2016 18:25:03 -0400
Received: by mail-it0-f47.google.com with SMTP id d65so72309100ith.0
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2016 15:25:03 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/5] Fix callback channel handling of referring triples
Date: Sun, 28 Aug 2016 18:21:00 -0400
Message-Id: <1472422865-28698-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RFC5661 has a mechanism for ensuring that the forward channel and backward
channel do not race. The Linux client implements this mechanism, but in
a manner that is racy, making it rather pointless, and buggy (Oops!).

This patch series fixes the most egregious issues around delegations and
layouts by ensuring that we wait for completion of the actual setup of
the delegation or layout that could be subject to recall.

Trond Myklebust (5):
  NFSv4.1: Fix Oopsable condition in server callback races
  NFSv4.1: Delay callback processing when there are referring triples
  NFSv4.1: Defer bumping the slot sequence number until we free the slot
  NFSv4.1: Close callback races for OPEN, LAYOUTGET and LAYOUTRETURN
  NFSv4.1: Remove obsolete and incorrrect assignment in
    nfs4_callback_sequence

 fs/nfs/callback_proc.c |  8 ++---
 fs/nfs/nfs4proc.c      | 89 +++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/nfs4session.c   | 53 ++++++++++++++++++++++++++++++
 fs/nfs/nfs4session.h   |  7 +++-
 4 files changed, 135 insertions(+), 22 deletions(-)

-- 
2.7.4

