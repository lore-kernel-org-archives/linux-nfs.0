Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:50474 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759317Ab3GRTfj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jul 2013 15:35:39 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 0/5] Avoid expired credential keys for buffered writes
Date: Thu, 18 Jul 2013 15:35:25 -0400
Message-ID: <1374176130-11657-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This code has been refactored since version 3, and the first two patches
are new.

Related code to destroy the gss context upon kdestoy that also uses some of the
underlying SUNRPC functionality will come in a separate patch set. 

-----------
Version 3, responded to comments:

1) Changed "SUNRPC Fix rpc_verify_header error returns" into
"SUNRPC refactor rpcauth_checkverf error returns" which only returns -EACCES on
rpcauth_checkverf error in gss_validate if -EKEYEXPIRED is returned.

Rebased on 3.7-rc7 Trond's testing branch.
-------------
Version 2, responded to comments:
1) Just use high water mark
2) Move expiration testing into nfs_file_write
3) Added a patch to clean up rpc_verify_header error processing

Edited explanation from version 3:

We must avoid buffering a WRITE that is using a credential key (e.g. a GSS
context key) that is about to expire.  We currently will paint ourselves into
a corner by returning success to the applciation for such a buffered WRITE,
only to discover that we do not have permission when we attempt to flush the
WRITE (and potentially associated COMMIT) to disk.  This results in the
the application thinking it has written more to disk than it actually has.

Pages for buffered WRITEs are allocated in nfs_write_begin where we have an
nfs_open_context and associated rpc_cred. This is a generic rpc_cred, NOT
the gss_cred used in the actual WRITE RPC. Each WRITE RPC call takes the generic
rpc_cred (or uses the 'current_cred') uid and uses it to lookup the associated
gss_cred and gss_context in the call_refresh RPC state. So, there is a
one-to-one association between the nfs_open_context generic_cred and a
gss_cred with a matching uid and a valid non expired gss context.

We need to check the nfs_open_context generic cred 'underlying' gss_cred
gss_context gc_expiry in nfs_write_begin to determine if there is enough
time left in the gss_context lifetime to complete the buffered WRITEs.

I've added a credential key expiry watermark, RPC_KEY_EXPIRE_TIMEO set to 240
seconds as a default and can be set via a module parameter as we need to
ensure there is time for any dirty data to be flushed.

If a WRITE is using a credential with a key that will expire within
watermark seconds, we flush the inode in nfs_write_end and send only
NFS_FILE_SYNC WRITEs.

TESTING:

We've begun testing upstream kernels mounting Kerberos shares, and will test
these changes for regressions.

I've tested the kernel without these changes, and then with these changes using
a modified Connectathon Special test5 that holds the file open and rewrites to
ensure that buffered writing is occuring as the GSS context expires.

I've verified that without this patch set, the bytes written that the test
application sees is more than the bytes written to the file system (ls -l0

I've verified that with a long enough watermark, the bytes written that the
test application calculates is equal to the bytes written to the file
system (ls -l).

-->Andy

Andy Adamson (5):
  SUNRPC: don't map EKEYEXPIRED to EACCES in call_refreshresult
  NFS: Warn when attempting a buffered write or commit with an expired
    credential
  SUNRPC new rpc_credops to test credential expiry
  NFS avoid expired credential keys for buffered writes
  SUNRPC refactor rpcauth_checkverf error returns

 fs/nfs/file.c                  | 19 +++++++++-
 fs/nfs/internal.h              |  2 ++
 fs/nfs/write.c                 | 37 +++++++++++++++++++
 include/linux/sunrpc/auth.h    | 16 +++++++++
 net/sunrpc/auth.c              | 21 +++++++++++
 net/sunrpc/auth_generic.c      | 82 ++++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c | 61 ++++++++++++++++++++++++++++---
 net/sunrpc/auth_null.c         |  5 +--
 net/sunrpc/auth_unix.c         |  5 +--
 net/sunrpc/clnt.c              | 19 +++++-----
 10 files changed, 250 insertions(+), 17 deletions(-)

-- 
1.8.3.1

