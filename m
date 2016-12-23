Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:7177 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753059AbcLWQGb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:06:31 -0500
From: <andros@netapp.com>
To: <anna.schumaker@netapp.com>
CC: <bfieldses.org@netapp.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 00/16] RFC: RPCSEC_GSS Version 3 prototype: Full Mode MAC
Date: Fri, 23 Dec 2016 11:04:12 -0500
Message-ID: <1482509068-24516-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This is a Request for Comment on this GSSv3 prototype that implements full
mode Mandatory Access Control (MAC) when run with NFSv4.2 Labeled NFS using
SeLinux MAC.

Note: I have 3 debug patches to verify functionality with _way_ to many printk
calls that display verifiers and context handle refcounts and labels
available upon request...

Requires:
--------
gssd patches:  "RFC: GSSD changes for RPCSEC_GSS version 3"
libtirpc patches "RFC: Libtirpc changes for RPCSEC_GSS version 3"

Prototye Features:
-----------------

GSSv3
- RPC_GSS_SVC_CHANNEL_PROT marked as unsupported
- Negotiate GSS version - start with GSSv3, fall back to GSSv1
- New GSSv3 reply verifier 
- RPCSEC_GSS_CREATE call
- label assertion payload carries each client SeLinux thread label
- Supports one label assertion payload per RPCSEC_GSS_CREATE
- Kerberos pseudoflavor support (krb5, krb5i, krb5p)

TODO:
----
- Ensure SeLinux function exported in patch
  SELINUX export security_current_sid_to_context" is OK.
- Add user configuration to indicate Full Mode MAC is desired and that
  NFSv4.2 Labeled NFS (LNFS) is used.

Prototype description:
---------------------
Parent GSS context: normal GSSv3 context
  - Same as a GSSv1 context except new GSS Version and new reply verifier
  - Called the parent contex
If SeLinux is enabled and GSSv3 is in use, assume LNFS and GSSv3 full mode MAC.

Each new GSS context (parent) kicks off an RPCSEC_GSS_CREATE with the
client thread's SeLinux label as a payload.
  - Upon success, creates a GSSv3 child context handle that asserts the
    thread label, and uses the parent context for encrytion services.
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

Each time a call is made, the clinet makes a check in gss_match to see if
the curren thread's SeLinux label has an associated GSS3 child context handle
to use. If not, an RPCSEC_GSS_CREATE call is kicked off to establish the
child context prior to the NFS request being sent. The NFS request then
uses the child context that asserts the client NFS request thread label
when sending the NFS request to the server.

Smoke Test;
----------
Setup:
- Ensure SeLinux is enabled on both client and server
- Turn on NFSv4.2 in client and server
  - SERVER: in /etc/sysconfig/nfs: RPCNFSDARGS="-V 4.2"
  - CLIENT: mount -o v4.2 <server>:<export> <mntpoint>
- Useful SeLinux commands
  - ls -Z  (shows label and fetches it via GETATTR usin LNFS)
  - ls -scontext  (shows just the label)

Test: (run with wireshark capture)
Note: labels and conext values are from my setup. I restart gssd each test run.
Note: my server /etc/export is "/export *(sec=krb5:sys,rw,no_root_squash)"

- # mount -o v4.2,sec=krb5 <server>:<export>  <mntpoint>
  # ls <mntpoint>
  - This will create a parent GSS context for kb5i (010000000000000 say 01),
    and a GSS3 child context for krb5i parent with the client thread
    label "system_u:system_r:kernel_t:s0" with handle 02.
   - The child handle 02 is used for the EXCHANGE_ID, CREATE_SESSION, and
     RECLAIM_COMPLETE calls.
  - Then a parent GSS handle is created for krb5 (03) and a GSS3 child
    context for the krb5 parent with hanel (04) for the client thread label
    "unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023"
   - The child handle 04 is used for the PUTROOT_FH, all the mount GETATTRs
     and the LOOKUP of "/export"
   - A new GSS3 child context (05) is created for krb5 parent with label
     "system_u:system_r:kernel_t:s0"
     The child handle 05 is used for LOOKUP, ACCESS, READDIR, etc.

- # umount <mntpoint>
   - This will create a new GSS3 child context (06) for krb5i parent with the
     client thread label
     "unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023"
    - The child handle 06 is used for DESTROY_SESSION and DESTROY_CLIENTID.
  - RPCSEC_GSS_DESTROY messages are sent for the two parent contexts 01 and 03.
  - CHILD: the parent contexts and associated child contexts are destroyed.
  - SERVER: the parent context and associated child contexts are destroyed.

-->Andy


Andy Adamson (15):
  SUNRPC handle unsupported RPC_GSS_SVC_CHANNEL_PROT
  SUNRPC: add a null call with payload GSSv3
  SELINUX export security_current_sid_to_context
  SUNRPC GSSv3: base definitions
  SUNRPC AUTH_GSS get RPCSEC_GSS version from gssd downcall
  SUNRPC AUTH_GSS gss3 reply verifier
  SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with label payload
  SUNRPC AUTH_GSS store and use gss3 label assertion
  SUNRPC AUTH_GSS free assertions
  SUNRPC: AUTH_GSS add RPC_GSS_PROC_CREATE case for wrap and unwrap
  SUNRPC SVCAUTH_GSS allow RPCSEC_GSS version 1 or 3
  SUNRPC SVCAUTH_GSS gss3 reply verifier
  SUNRPC SVCAUTH_GSS gss3 create label
  SUNRPC SVCAUTH_GSS set gss3 label on nfsd thread
  SUNRPC SVCAUTH_gss store gss3 child handles in parent rsc

Neil Brown (1):
  SUNRPC SVCAUTH_GSS reap the rsc cache entry on RPC_GSS_PROC_DESTROY

 fs/nfsd/auth.c                     |  11 +-
 include/linux/selinux.h            |   1 +
 include/linux/sunrpc/auth_gss.h    |  76 +++++-
 include/linux/sunrpc/cache.h       |   1 +
 include/linux/sunrpc/clnt.h        |   3 +
 include/linux/sunrpc/gss_api.h     |  11 +
 include/linux/sunrpc/svcauth.h     |   1 +
 include/linux/sunrpc/svcauth_gss.h |   1 +
 net/sunrpc/auth_gss/auth_gss.c     | 509 +++++++++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/svcauth_gss.c  | 522 +++++++++++++++++++++++++++++++++++--
 net/sunrpc/cache.c                 |  13 +
 net/sunrpc/clnt.c                  |  20 ++
 security/selinux/hooks.c           |  12 +
 13 files changed, 1141 insertions(+), 40 deletions(-)

-- 
1.8.3.1

