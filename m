Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:44304 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758563AbcLWQLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:11:45 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH] RFC: GSSD changes for RPCSEC_GSS version 3
Date: Fri, 23 Dec 2016 11:09:47 -0500
Message-ID: <1482509388-22430-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is a Request for Comment patch set for the GSSv3 prototype.

Requires:

- kernel patches: "RFC: RPCSEC_GSS Version 3 prototype: Full MOde MAC
- libtirpc patches: "RFC: Libtirpc changes for RPCSEC_GSS version 3"

Andy Adamson (1):
  GSSD: Add RPCSEC_GSS version to downcall

 utils/gssd/gssd_proc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

-- 
1.8.3.1

