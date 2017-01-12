Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:35193 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750843AbdALXCp (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jan 2017 18:02:45 -0500
Received: by mail-it0-f52.google.com with SMTP id 203so22085997ith.0
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jan 2017 15:02:44 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/4] Fix update_changeattr
Date: Thu, 12 Jan 2017 18:02:36 -0500
Message-Id: <20170112230240.7730-1-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Several of the calls to update_changeattr() are causing the directory
attribute cache to be flushed in cases where it simply isn't neccessary.

---
v2: add patch to update the directory attribute cache timestamp

Trond Myklebust (4):
  NFSv4: Call update_changeattr() from _nfs4_proc_open only if a file
    was created
  NFSv4: Don't apply change_info4 twice on rename within a directory
  NFSv4: Don't call update_changeattr() unless the unlink is successful
  NFSv4: update_changeattr should update the attribute timestamp

 fs/nfs/nfs4proc.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

-- 
2.9.3

