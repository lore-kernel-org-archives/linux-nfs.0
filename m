Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:6166 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941241AbcLWQLC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:11:02 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 0/2] RFC: Libtirpc changes for RPCSEC_GSS version 3
Date: Fri, 23 Dec 2016 11:09:25 -0500
Message-ID: <1482509367-22381-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is a Request for Comment patch set for the GSSv3 prototype.

Requires:

- kernel patches: "RFC: RPCSEC_GSS Version 3 prototype: Full MOde MAC
- gssd patches: "RFC: GSSD changes for RPCSEC_GSS version 3"


Andy Adamson (2):
  Use RPCSEC_GSS version 3
  RPCSEC_GSSv3 new reply verifier

 autogen.sh           |   0
 src/auth_gss.c       | 195 +++++++++++++++++++++++++++++++++++++++++++++++++--
 src/clnt_vc.c        |   1 +
 src/debug.c          |   2 +-
 tirpc/rpc/auth_gss.h |  10 ++-
 5 files changed, 198 insertions(+), 10 deletions(-)
 mode change 100644 => 100755 autogen.sh

-- 
1.8.3.1

