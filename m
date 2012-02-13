Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ey0-f174.google.com ([209.85.215.174]:62957 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754236Ab2BMVv0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2012 16:51:26 -0500
Received: by eaah12 with SMTP id h12so1933716eaa.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Feb 2012 13:51:25 -0800 (PST)
From: Tigran Mkrtchyan <kofemann@googlemail.com>
To: linux-nfs@vger.kernel.org, bhalevy@tonian.com, bfields@fieldses.org
Cc: Tigran Mkrtchyan <kofemann@gmail.com>
Subject: [PATH v9 00/10] handle curruent stateid
Date: Mon, 13 Feb 2012 22:54:34 +0100
Message-Id: <1329170084-7032-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Tigran Mkrtchyan <kofemann@gmail.com>

With Benny's comments.

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


Coresponding pynfs test already submited.

Tigran.
Tigran Mkrtchyan (10):
  nfsd4: initialize current stateid at compile time
  nfsd41: handle current stateid in open and close
  nfsd41: handle current stateid on lock and locku
  nfsd41: consume current stateid on read and write
  nfsd41: mark PUTFH, PUTPUBFH and PUTROOTFH to clear current stateid
  nfsd41: save and restore current stateid with current fh
  nfsd41: mark LOOKUP, LOOKUPP and CREATE to invalidate current stateid
  nfsd41: handle current stateid in SETATTR and FREE_STATEID
  nfsd41: consume current stateid on DELEGRETURN and OPENDOWNGRADE
  nfsd41: use current stateid by value

 fs/nfsd/current_stateid.h |   28 ++++++++++++
 fs/nfsd/nfs4proc.c        |   61 +++++++++++++++++++++----
 fs/nfsd/nfs4state.c       |  107 ++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/xdr4.h            |   11 +++++
 4 files changed, 196 insertions(+), 11 deletions(-)
 create mode 100644 fs/nfsd/current_stateid.h

-- 
1.7.7.6

