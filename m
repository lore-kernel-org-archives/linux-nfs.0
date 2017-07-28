Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:56639 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752505AbdG1UWD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:22:03 -0400
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <trond.myklebust@primarydata.com>, <bfields@redhat.com>,
        <olga.kornievskaia@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 6 00/12] RPCSEC_GSS Version 3 Full MOde MAC Labeling
Date: Fri, 28 Jul 2017 16:21:46 -0400
Message-ID: <1501273318-14200-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Version 6:
- Implemented GSSv3 security for NFSv4.2 Inter Server to Server copy on
  top of this code. copy_to_auth, copy_from_auth, and copy_confirm_auth
  payloads should not impose changes to this GSSv3 label code.

Requires on Client:
-------------------
gssd patches:  "Version 4 GSSD changes for RPCSEC_GSS version 3"
        0001-GSSD-Add-RPCSEC_GSS-version-to-downcall.patch
        0002-GSSD-add-option-to-not-put-gss-version-in-downcall.patch

libtirpc patches "Version 4 Libtirpc changes for RPCSEC_GSS version 3"
        0001-Use-RPCSEC_GSS-version-3.patch
        0002-RPCSEC_GSSv3-new-reply-verifier.patch

GSSv3 Implementation Features:
------------------------------
- Negotiate GSS version - starts with GSSv3 then falls back to GSSv1 if
  GSSv3 is not supported by gssd or by the NFS server.
- New GSSv3 reply verifier over the RPC header and credential, just like the call verifier caveat the "REPLY" direction. This new reply verifier is stronger than the GSSv1 reply verifier which is only over the GSS sequence number.
- RPCSEC_GSS_CREATE operation generic code is separated from the payload code.
- The first time each client SeLinux thread label is used, an RPCSEC_GSS_CREATE call with a rgss3_label assertion payload is sent, and a GSS3 Child context is associated with the thread label. Each use of the client thread label triggers the use of the associated GSS3 child context handle for the NFS request
- Supports one label assertion payload per RPCSEC_GSS_CREATE
- Kerberos pseudoflavor support (krb5i, krb5p) for RPCSEC_GSS_CREATE calls.
- RPCSEC_GSS_CREATE is only used on krb5i or krb5p parent contexts.
- Client only uses GSSv3 labeling if GSSv3 is in use, selinux is enabled,
  and the credential used has the RPC_SEC_GSS_KRB5I or RPC_SEC_GSS_KRB5P
  auth flavor.

Issues:
-------
- Perhaps add an administrative configuration on the client (a mount option?)
  to indicate Full Mode MAC is desired and that NFSv4.2 Labeled NFS (LNFS)
  is to be used. The current code checks the rpc_auth au_flavor in the
  GSS layer. This can result in labels being sent only on the
  RPC_SEC_GSS_KRB5I state management NFS requests (EXCHANGE_ID,
  CREATE_SESSION, etc) on KRB5, AUTH_SYS, and AUTH_NONE mounts where
  the non state management NFS requests will not use GSSv3 label contexts.
  An administrative configuration can clear up this confusion.

- When GSSv3 labeling is configured, should NFS requests fail if a GSSv3 label
  fails to be created? Should we count on the server failing an NFS request
  without an associated GSS3 label context handle? The current code ignores
  an RPCSEC_GSS_CREATE failure.

Functional Description
----------------------
Parent GSS context: the normal GSS context
 - "Normal" GSSv3 context is the same as a "normal" GSSv1 context except
   for the new GSS Version and new reply verifier. For GSSv3 this "normal"
   context is called the parent context.

Child GSS3 context: Is returned by a successful RPCSEC_GSS_CREATE operation
 - Child context is associated with the parent context on both the client
   and the server.

Client:
    If SeLinux is enabled, GSSv3 is in use, and this is a sec=krb5i or
    sec=krb5p mount option, assume LNFS and GSSv3 full mode MAC security
    (caveat the first Issue above).

Server:
    If SeLinux is enabled, the NFSEXP_SECURITY_LABEL is set on the export,
    (export option "security_label") and GSSv3 is in use, then both LNFS
    and GSSv3 labels are in use e.g.  full mode MAC security.

When full mode MAC is used:
  - Each new GSS3 context (parent) kicks off an RPCSEC_GSS_CREATE with the
    client thread's SeLinux label as a payload.
  - Upon success, the RPCSEC_GSS_CREATE call creates a GSSv3 child context
    handle that asserts the thread label, and uses the parent context for
    encrytion services.
  - CLIENT: Child context and assertion is stored in an assertion list
    off the struct gss_cl_ctx.
  - SERVER: Child context has it's own rsc cache entry, and the child
    handle is stored in a list of children handles off the parent rsc entry.
  - CLIENT and SERVER: child contexts are destroyed when parent context is
    destroyed.
  - CLIENT: child context associated with the client NFS request thread
    is used for the NFS request.
  - SERVER: Using the child context handle looks up the child rsc entry.
    Using the parent context handle stored in the child rsc entry looks up
    the parent rsc entry to use for MIC creation/verification, integrity
    (krb5i)  and/or privacy (krb5p).
  - SERVER: the label asserted by the NFS request child handle is imposed
    upon the NFSD thread servicing the request just like the UID/GIDs in
    the rpc credential.

Each time a call is made, the client makes a check in gss_match to see if
the curren thread's SeLinux label has an associated GSS3 child context handle
to use. If not, an RPCSEC_GSS_CREATE call is kicked off to establish the
child context prior to the NFS request being sent. The NFS request then
uses the child context that asserts the client NFS request thread label
when sending the NFS request to the server.

Useful SeLinux commands
------------------------
  - getenforce    will let you know if Selinux is enforced
  - ls -Z         shows label and fetches it via LNFS GETATTR
  - ls -scontext  shows just the label
                                                              105,1  
Andy Adamson (12):
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

 fs/nfsd/auth.c                     |  11 +-
 include/linux/selinux.h            |   7 +
 include/linux/sunrpc/auth_gss.h    |  72 ++++-
 include/linux/sunrpc/gss_api.h     |   9 +
 include/linux/sunrpc/svcauth.h     |   1 +
 include/linux/sunrpc/svcauth_gss.h |   1 +
 net/sunrpc/auth_gss/auth_gss.c     | 606 ++++++++++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/svcauth_gss.c  | 605 ++++++++++++++++++++++++++++++++++--
 security/selinux/hooks.c           |  10 +
 9 files changed, 1281 insertions(+), 41 deletions(-)

-- 
1.8.3.1

