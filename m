Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47453 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab2AOQR2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 11:17:28 -0500
Received: by eaae11 with SMTP id e11so75323eaa.19
        for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 08:17:27 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v6 0/9] handle curruent stateid
Date: Sun, 15 Jan 2012 17:20:01 +0100
Message-Id: <1326644410-7482-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>


This is ready-to-go patch set. Rebased to Bruce's nfsd-next.

Implemented for:

  OPEN
  OPENDOWNGRADE 
  CLOSE
  LOCK
  LOCKU
  DELEGRETURN
  FREE_STATEID
  SETATTR
  READ
  WRITE
  SAVEFH
  RESTOREFH
  PUTFH
  PUTROOTFH
  PUTPUBFH
  LOOKUP
  CREATE 

PNFS released patches will be submitted as soon as patches will be merged with Benny's tree.

I will clean-up and submit corresponding pynfs test later today or tomorrow.

Comments and suggestions are welcome

Tigran.

Tigran Mkrtchyan (9):
  nfsd4: initialize current stateid at compile time
  nfsd41: handle current stateid in open and close
  nfsd41: handle current stateid on lock and locku
  nfsd41: consume current stateid on read and write
  nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
  nfsd41: save and restore current stateid with current fh
  nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
  nfsd41: handle current stateid in SETATTR and FREE_STATEID
  nfsd41: consume current stateid on DELEGRETURN and OPENDOWNGRADE

 fs/nfsd/current_stateid.h |   27 ++++++++++++
 fs/nfsd/nfs4proc.c        |   55 ++++++++++++++++++++-----
 fs/nfsd/nfs4state.c       |   99 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/xdr4.h            |    2 +
 4 files changed, 172 insertions(+), 11 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h

-- 
1.7.7.5

