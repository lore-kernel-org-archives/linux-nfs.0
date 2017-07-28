Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:53029 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752944AbdG1Uu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:50:26 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <anna.schumaker@netapp.com>, <olga.kornievskaia@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 0/2] GSSD changes for RPCSEC_GSS version 3
Date: Fri, 28 Jul 2017 16:50:20 -0400
Message-ID: <1501275022-24313-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Adds RPCSEC_GSS version 3 negotiation to GSSD

Requires
--------
libtirpc patches "Version 4 Libtirpc changes for RPCSEC_GSS version 3"
        0001-Use-RPCSEC_GSS-version-3.patch
        0002-RPCSEC_GSSv3-new-reply-verifier.patch

kernel: RPCSEC_GSS Version 3 Full MOde MAC Labeling
        SELINUX export security_current_sid_to_context
        SUNRPC GSSv3: base definitions
        SUNRPC AUTH_GSS get RPCSEC_GSS version from gssd downcall
        SUNRPC AUTH_GSS gss3 reply verifier
        SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with label payload
        SUNRPC AUTH_GSS store and use gss3 label assertion
        SUNRPC-AUTH_GSS gss3_free_assertions
        SUNRPC SVCAUTH_GSS allow RPCSEC_GSS version 1 or 3
        SUNRPC SVCAUTH_GSS gss3 reply verifier
        SUNRPC SVCAUTH_GSS gss3 create label
        SUNRPC SVCAUTH_GSS set gss3 label on nfsd thread
        SUNRPC SVCAUTH_gss store gss3 child handles in parent rsc

GSSD netotiates RPCSEC_GSS version 3 contexts with server, and falls back
RPCSEC_GSS version 1 upon AUTH_ERR.

New GSSD option "-G" turns off GSSv3 negotation so that RPCSEC_GSS version 1
only is used

Andy Adamson (2):
  GSSD: Add RPCSEC_GSS version to downcall
  GSSD add option to not put gss version in downcall

 configure.ac           |  1 +
 utils/gssd/gssd.c      |  9 +++++++--
 utils/gssd/gssd.h      |  1 +
 utils/gssd/gssd_proc.c | 17 +++++++++++++++--
 4 files changed, 24 insertions(+), 4 deletions(-)

-- 
1.8.3.1

