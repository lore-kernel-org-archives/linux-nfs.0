Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:52563 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751163AbdBXWUD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 24 Feb 2017 17:20:03 -0500
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <schumaker.anna@gmail.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 5 00/17] RPCSEC_GSS3 full mode label kernel patch set
Date: Fri, 24 Feb 2017 17:19:36 -0500
Message-ID: <20170224221953.5502-1-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This patchset implements RFC 7861  RPCSEC_GSS Version 3 RPCSEC_GSS_CREATE
operation with rgs3_label payloads to provide  full mode Mandatory Access
Control (MAC) when run with NFSv4.2 Labeled NFS using SeLinux.

A lot more testing is needed - and planned :)

Client was built on Trond's testing branch, 4.10.0 kernel.
Server was  built on Bruce's nfsd-next branch, 4.10.0-rc7 kernel

nfsd-next branch has these server required patches missing from Tronds
testing branch:

1) svcrpc: free contexts immediately on PROC_DESTROY
2) nfsd: opt in to labeled nfs per export

Version-5.
---------
- responded to comments from Anna Schumaker
- refactored code to split generice RPCSEC_GSS_CREATE from label payload
- nfsd check for NFSEXP_SECURITY_LABEL export flag

Requires on Client:
-------------------
gssd patches:  "RFC: GSSD changes for RPCSEC_GSS version 3"
libtirpc patches "RFC: Libtirpc changes for RPCSEC_GSS version 3"

Implementation Features:
------------------------

GSSv3
- Negotiate GSS version - starts with GSSv3 then falls back to GSSv1 if
  GSSv3 is not supported.
- New GSSv3 reply verifier
- RPCSEC_GSS_CREATE operation generic code is separated from the payload code.
- rgss3_label assertion payload carries each client SeLinux thread label
- Supports one label assertion payload per RPCSEC_GSS_CREATE
- Kerberos pseudoflavor support (krb5, krb5i, krb5p)

TODO:
----
- Send all RPCSEC_GSS_CREATE calls with integrity or privacy
- Ensure SeLinux function exported in patch "SELINUX export
  security_current_sid_to_context" is OK with SeLinux experts.
- Perhaps add administrative ability on the client to indicate Full Mode
  MAC is desired and that NFSv4.2 Labeled NFS (LNFS) is used.

Prototype description:
---------------------
Parent GSS context: the normal GSS context
 - "Normal" GSSv3 context is the same as a "normal" GSSv1 context except
   for the new GSS Version and new reply verifier. For GSSv3 this "normal"
   context is called the parent context.

Child GSS3 context: Is returned by a successful RPCSEC_GSS_CREATE operation
 - Child context is associated with the parent context on both the client
   and the server.

If SeLinux is enabled and GSSv3 is in use, assume LNFS and GSSv3 full mode MAC.

When Full Mode MAC is used:
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

Smoke Test;
----------
Setup:
- Ensure SeLinux is enabled on both client and server
- Turn on NFSv4.2 in client and server
  - SERVER: in /etc/sysconfig/nfs: RPCNFSDARGS="-V 4.2" (not needed in
    Fedora 25 as NFSv4.2 is turned on)
  - Fedora 25 SERVER export option "security_label" must be set:
    /export *(sec=krb5:sys,rw,no_subtree_check,no_root_squash,security_label)
  - CLIENT: mount -o v4.2 <server>:<export> <mntpoint>
  - Note: LNFS sends the file label in the OPEN compound GETATTR.
  - GSS3 sends the client thread label in the RPCSEC_GSS_CREATE call.
- Useful SeLinux commands
  - getenforce (setenforce) will let you know if Selinux is enforced
  - ls -Z  (shows label and fetches it via GETATTR usin LNFS)
  - ls -scontext  (shows just the label)

Note: Server should be Fedora 25 as the nfs-utils-2.1.1.2.rc1.fc25 and
kernel 5.9.10-200.fc25 supports the new "security_label" export option
which needs to be set on an exported file system that wants to support
LNFS and GSS3 labels.

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


Andy Adamson (17):
  SUNRPC handle unsupported RPCSEC_GSS security service
  SUNRPC: RPCNULL call with payload for GSSv3
  SELINUX export security_current_sid_to_context
  SUNRPC GSSv3: base definitions
  SUNRPC AUTH_GSS get RPCSEC_GSS version from gssd downcall
  SUNRPC AUTH_GSS gss3 reply verifier
  SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with no payload
  SUNRPC AUTH_GSS RPCSEC_GSS_CREATE with label payload
  SUNRPC AUTH_GSS store GSS3 assertions in parent gss_cl_ctx
  SUNRPC AUTH_GSS store and use gss3 label assertion
  SUNRPC AUTH_GSS free assertions
  SUNRPC: AUTH_GSS add RPC_GSS_PROC_CREATE case for wrap and unwrap
  SUNRPC SVCAUTH_GSS allow RPCSEC_GSS version 1 or 3
  SUNRPC SVCAUTH_GSS gss3 reply verifier
  SUNRPC SVCAUTH_GSS gss3 create label
  SUNRPC SVCAUTH_GSS set gss3 label on nfsd thread
  SUNRPC SVCAUTH_gss store gss3 child handles in parent rsc

 fs/nfsd/auth.c                     |  11 +-
 include/linux/selinux.h            |   7 +
 include/linux/sunrpc/auth_gss.h    |  76 ++++-
 include/linux/sunrpc/clnt.h        |   3 +
 include/linux/sunrpc/gss_api.h     |  11 +
 include/linux/sunrpc/svcauth.h     |   1 +
 include/linux/sunrpc/svcauth_gss.h |   1 +
 net/sunrpc/auth_gss/auth_gss.c     | 564 ++++++++++++++++++++++++++++++++++++-
 net/sunrpc/auth_gss/svcauth_gss.c  | 549 ++++++++++++++++++++++++++++++++++--
 net/sunrpc/clnt.c                  |  20 ++
 security/selinux/hooks.c           |  14 +
 11 files changed, 1217 insertions(+), 40 deletions(-)

-- 
2.9.3

