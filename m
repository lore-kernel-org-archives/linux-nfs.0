Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-out-2.desy.de ([131.169.56.85]:58059 "EHLO
	smtp-out-2.desy.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751527Ab2AOTCo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jan 2012 14:02:44 -0500
Received: from smtp-map-2.desy.de (smtp-map-2.desy.de [131.169.56.67])
	by smtp-out-2.desy.de (DESY_OUT_1) with ESMTP id C9C36C1A
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:42 +0100 (MET)
Received: from ZITSWEEP3.win.desy.de (zitsweep3.win.desy.de [131.169.97.97])
	by smtp-map-2.desy.de (DESY_MAP_2) with ESMTP id 8A6D8BA6
	for <linux-nfs@vger.kernel.org>; Sun, 15 Jan 2012 20:02:40 +0100 (MET)
From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To: linux-nfs@vger.kernel.org, bfields@fieldses.org
Cc: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH 0/5] more test on current stateid processing
Date: Sun, 15 Jan 2012 20:05:23 +0100
Message-Id: <1326654328-20557-1-git-send-email-tigran.mkrtchyan@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


This is the result of testing my changes in linux:

$ ./testserver.py  --maketree 192.168.178.20:/tmp currentstateid
.....

**************************************************
CSID1    st_current_stateid.testOpenAndClose                      : PASS
CSID2    st_current_stateid.testLockLockU                         : PASS
CSID3    st_current_stateid.testOpenWriteClose                    : PASS
CSID4    st_current_stateid.testLockWriteLocku                    : PASS
CSID5    st_current_stateid.testOpenPutrootfhClose                : PASS
CSID6    st_current_stateid.testCloseNoStateid                    : PASS
CSID7    st_current_stateid.testOpenLayoutGet                     : FAILURE
           OP_LAYOUTGET should return NFS4_OK, instead got
           NFS4ERR_NOTSUPP
CSID8    st_current_stateid.testOpenSetattr                       : PASS
CSID9    st_current_stateid.testOpenFreestateidClose              : PA

**************************************************
$

Tigran Mkrtchyan (5):
  client: move current stateid test into a dedicated module
  client: test current stateid processing on PUTROOTFH
  client: test current stateid processing with OPEN+LAYOUTGET in a
    single compound
  client: test current stateid processing with OPEN and SETATTR
  client: test OPEN+FREE_STETEID+CLOSE in a single compound

 nfs4.1/server41tests/__init__.py           |    1 +
 nfs4.1/server41tests/st_current_stateid.py |  161 ++++++++++++++++++++++++++++
 nfs4.1/server41tests/st_open.py            |   76 -------------
 3 files changed, 162 insertions(+), 76 deletions(-)
 create mode 100644 nfs4.1/server41tests/st_current_stateid.py

-- 
1.7.7.5

