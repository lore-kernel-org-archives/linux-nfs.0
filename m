Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:10649 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752908AbdG1UuE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:50:04 -0400
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <anna.schumaker@netapp.com>, <olga.kornievskaia@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 0/2]  Libtirpc changes for RPCSEC_GSS version 3
Date: Fri, 28 Jul 2017 16:49:58 -0400
Message-ID: <1501275000-24236-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version 4

Requires on Client:
-------------------
gssd patches:  "Version 4 GSSD changes for RPCSEC_GSS version 3"
        0001-GSSD-Add-RPCSEC_GSS-version-to-downcall.patch
	0002-GSSD-add-option-to-not-put-gss-version-in-downcall.patch

To use GSSv3:
-------------
kernel patches: "Version 6 RPCSEC_GSS Version 3 Full MOde MAC Labeling"
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

Compatibility
-------------
GSSv3 enabled GSSD (libtirpc + gssd patches) is backwards compatible with
client kernels that do not support GSSv3. GSSD negotiates the GSS version,
starting with GSSv3 and falling back to GSSv1.

GSSD has a new option for turning off GSSv3 negotiation.

Andy Adamson (2):
  Use RPCSEC_GSS version 3
  RPCSEC_GSSv3 new reply verifier

 autogen.sh           |   0
 src/auth_gss.c       | 152 ++++++++++++++++++++++++++++++++++++++++++++++++---
 src/clnt_vc.c        |   1 +
 tirpc/rpc/auth_gss.h |   8 ++-
 4 files changed, 153 insertions(+), 8 deletions(-)
 mode change 100644 => 100755 autogen.sh

-- 
1.8.3.1

