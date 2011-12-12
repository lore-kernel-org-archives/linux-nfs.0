Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:62622 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab1LLU6Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 15:58:24 -0500
Received: by eekc4 with SMTP id c4so1814320eek.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Dec 2011 12:58:22 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v4 0/3] nfsd41: current state id processing
Date: Mon, 12 Dec 2011 22:00:24 +0100
Message-Id: <1323723627-413-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


Yet another update (v4) of current stateid handling

difference with v3:

Patches re-organized to only add functionality, e.g. there
are no patches fixing other patches. Operation flags are
not used any more. Existence of a corresponding function
pointer is enough.


Let me know if you want to see updates less often.

Tigran.

currently tested to work in a single compound:

 OPEN+CLOSE
 LOCK+WRITE+LOCKU+CLOSE

On the way (not tested yet):
 OPEN+LAYOUTGET

TODO:
 dispose current stateid on operations which provide CFH, but do not provide stateid.

Internals:
 1. struct nfsd4_compound_state contains pointer to current stateid
 2. during compound processing before operation execution current stateid copied into
  operations stateid if it's equal to corresponding value ( 0, 1).
 3. after operation execution current stateid changed to:
    a) point to stateid of last operation
    or
    b) point to NULL, if operation is marked to do so.

Probably all patches have to be squashed into a single one before merged
as none of the changes makes sense without others.

Tigran.


Tigran Mkrtchyan (3):
  nfsd41: handle current stateid in open and close
  nfsd41: handle current stateid on lock and locku
  nfsd41: consume current stateid on read and write

 fs/nfsd/current_stateid.h |   22 +++++++++++++++
 fs/nfsd/nfs4proc.c        |   39 +++++++++++++++++++++++---
 fs/nfsd/nfs4state.c       |   66 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h            |    1 +
 4 files changed, 123 insertions(+), 5 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h

-- 
1.7.7.4

