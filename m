Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40918 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752112Ab1LKQjz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Dec 2011 11:39:55 -0500
Received: by eekc4 with SMTP id c4so1219348eek.19
        for <linux-nfs@vger.kernel.org>; Sun, 11 Dec 2011 08:39:53 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v3 0/5] nfsd41: current state id processing
Date: Sun, 11 Dec 2011 17:41:43 +0100
Message-Id: <1323621708-25138-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>

This is yet another update of current stateid handling

currently tested to work in a single compound:

  OPEN+CLOSE
  LOCK+WRITE+LOCKU+CLOSE

On the way ( not tested yet ):
 OPEN+LAYOUTGET

TODO:
  dispose current stateid on operations which provide CFH, but do not provide stateid.

Internals:
  1. struct nfsd4_compound_state contains pointer to current stateid
  2. operations marked to PROVIDE, CONSUME or CLEAR current stateid. 
  3. during compound processing before operation execution current stateid copied into
   operations stateid if it's equal to corresponding value ( 0, 1).
  4. after operation execution current stateid changed to:
     a) point to stateid of last operation
     or
     b) point to NULL, if operation is marked to do so.


Probably all patches have to be squashed into a single one before merged
as none of the changes makes sense without others.

Tigran.

Tigran Mkrtchyan (5):
  nfsd41: handle current stateid in open and close
  nfsd41: handle current stateid on lock and locku
  nfsd41: update operations's stateid iff current stateid is set
  nfsd41: consume current stateid on read and write
  nfsd41: use pinter to current stateid to avoid extra copy

 fs/nfsd/current_stateid.h |   22 +++++++++++++++
 fs/nfsd/nfs4proc.c        |   55 +++++++++++++++++++++++++++++-------
 fs/nfsd/nfs4state.c       |   67 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h            |    1 +
 4 files changed, 134 insertions(+), 11 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h

-- 
1.7.7.4

