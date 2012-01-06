Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-bk0-f46.google.com ([209.85.214.46]:50458 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754930Ab2AFJmq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Jan 2012 04:42:46 -0500
Received: by bkcjm19 with SMTP id jm19so273092bkc.19
        for <linux-nfs@vger.kernel.org>; Fri, 06 Jan 2012 01:42:44 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v5 0/8] process current stateid
Date: Fri,  6 Jan 2012 10:45:08 +0100
Message-Id: <1325843116-20570-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>

Yet another update (v5) of current stateid handling

re-based to Benny's git branch pnfs-all-latest ( to include PNFS operations ) 

Includes a patch from Bruce f32f3c2d3f09a586349ca9180885dc8741290fd9

I have tested:

OPEN+READ+CLOSE
OPEN+WRITE+CLOSE
OPEN+LOCK+WRITE+LOCKU+CLOSE
OPEN+PUTROOTFH+CLOSE


implemented but not tested
OPEN+LAYOUTGET

Tigran.

Tigran Mkrtchyan (8):
  nfsd4: initialize special stateid's at compile time
  nfsd41: handle current stateid in open and close
  nfsd41: handle current stateid on lock and locku
  nfsd41: consume current stateid on read and write
  nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
  nfsd41: save and restore current stateid with current fh
  nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
  nfsv41: handle current stateid on LAYOUTGET

 fs/nfsd/current_stateid.h |   23 +++++++++++
 fs/nfsd/nfs4proc.c        |   53 ++++++++++++++++++++-----
 fs/nfsd/nfs4state.c       |   95 ++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h            |    2 +
 4 files changed, 158 insertions(+), 15 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h

-- 
1.7.7.5

