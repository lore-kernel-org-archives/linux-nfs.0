Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:27494 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756067Ab2K0Peg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 10:34:36 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 3 0/5] Avoid expired credential keys for buffered writes
Date: Tue, 27 Nov 2012 10:34:18 -0500
Message-Id: <1354030463-2372-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

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

NOTE: Often "Input/output error" is returned instead of
"Permission Denied". This is because of nfs_wb_all(). The NFS layer returns
-EACCES, but it gets mapped to -EIO (I believe via AG_EIO).
I would like to have Permision Denied always be returned...

NOTE: I will add a patch for directIO and look into mmaped I/O as well after
this patch set is done.

-------------

We must avoid buffering a WRITE that is using a credential key (e.g. a GSS
context key) that is about to expire or has expired.  We currently will
paint ourselves into a corner by returning success to the applciation
for such a buffered WRITE, only to discover that we do not have permission when
we attempt to flush the WRITE (and potentially associated COMMIT) to disk.
This results in data corruption.

First, a couple of "setup" patches:
1) Patch SUNRPC handle EKEYEXPIRED in call_refreshresult returns EACCES to the
application on an expired or non-existent gss context when the users (Kerberos)
credentials have also expired or are non-existent. Current behavior is to
retry upcalls to GSSD forever. Please see patch comment for detail.

2) Patch SUNRPC set gss gc_expiry to full lifetime works in conjunction with
the gssd patch "0001-GSSD-Pass-GSS_context-lifetime-to-the-kernel". The
gssd patch passes the actual remaining TGT lifetime in the downcall, and
this kernel patch sets the gss context gc_expiry to this lifetime.

Then the two patches that avoid using an expired credential key:
3) Patch SUNRPC new rpc_credops to test credential expiry is the heart of this
work. It provides the RPC layer helper functions to allow NFS to manage
data in the face of expired credentials

4) Patch NFS avoid expired credential keys for buffered writes calls the
RPC helper functions.

5) Patch SUNRPC Fix rpc_verify_header error returns changes a -EIO return to
a -EACCES return when there is an auth error.

Pages for buffered WRITEs are allocated in nfs_write_begin where we have an
nfs_open_context and associated rpc_cred. This is a generic rpc_cred, NOT
the gss_cred used in the actual WRITE RPC. Each WRITE RPC call takes the generic
rpc_cred (or uses the 'current_cred') uid and uses it to lookup the associated
gss_cred and gss_context in the call_refresh RPC state. So, there is a
one-to-one association between the nfs_open_context generic_cred and a
gss_cred with a matching uid and a valid non expired gss context.

We need to check the nfs_open_context generic cred 'underlying' gss_cred
gss_context gc_expiry prior to nfs_write_begin in nfs_file_write to determine
if there is enough time left in the gss_context lifetime to complete the
buffered WRITEs.

I started by adding a "key_timeout" rpc_authops routine only set by the generic
auth to do this work, called by rpcauth_key_timeout_notify, called from
nfs_write_begin. It does the lookup of the gss_cred (see the patch for
fast-tracking of non-gss underlying creds) and then tests the gss_context
gc_expiry against timeouts by calling a new crkey_timeout rpc_credops set
only for the gss_cred.

I coded a water mark, RPC_KEY_EXPIRE_TIMEO set to 90 seconds.
NOTE: this timeout is a guess that works in a VM environment. We may want to
make it adjustable via a module parameter.

If key_timeout is called on a credential with an underlying credential key that
will expire within watermark seconds, we set the RPC_CRED_KEY_EXPIRE_SOON
flag in the generic_cred acred so that the NFS layer can clean up prior to
key expiration It does this by calling a new crkey_to_expire rpc_credop set
only for generic creds that tests for the RPC_CRED_KEY_EXPIRE_SOON flag.

If the RPC_CRED_KEY_EXPIRE_SOON flag is set in the nfs_open_context generic
cred (the acred portion), then nfs_file_write will call vfs_fsync
on EVERY WRITE CALL it sees, and will send NFS_FILE_SYNC WRITEs.  The idea
of the watermark is to give time to flush all buffered WRITEs and COMMITs,
as well as to continue to WRITE, but only with NFS_FILE_SYNC, allowing the
application to try to finish writing before the gss context expires.
NOTE that this means EACH WRITE within the watermark
timeout is a singe PAGE of NFS_FILE_SYNC. I think this is fine, because we are
in a failure mode - the most important thing is to NOT fail a buffered WRITE..

Checking a generic credential's underlying credential involves a cred lookup.
To avoid this lookup in the normal case when the underlying credential has
a key that is valid (before the watermark), a notify flag is set in
the generic credential the first time the key_timeout is called. The
generic credential then stops checking the underlying credential key expiry, and
the underlying credential (gss_cred) match routine then checks the key
expiration upon each normal use and sets a flag in the associated generic
credential only when the key expiration is within the watermark.
This in turn signals the generic credential key_timeout to perform the extra
credetial lookup thereafter.

TESTING:

I have tested these patches with a TGT of 2 minutes, and the Connectathon
special test: bigfile.c with a 60MB bigfile size.

I kinit, and run 5 instances of buffered write with the first and maybe second
test completing prior to TGT expiration, and the third/fourth tests spanning
the water mark. The fifth test starts within the water mark.

I have seen the expected behavior: test 1,2 succeed. Tests 3-5 fail with
Permission Denied. Tests 3 and 4 start with normal buffered UNSTABLE writes
then switch to single page NFS_FILE_SYNC writes with a COMMIT for the
normal buffered writes. Test 5 has only single page NFS_FILE_SYNC writes.

None of the WRITEs fail on the wire, no failed WRITEs are returned as
successful to the application.

ISSUES:

The only issue is once in a while I see "Input/Output Error" instead of
"Permission denied". I believe the -EACCES error is translated into an -EIO
error in the VFS.

-->Andy


Andy Adamson (5):
  SUNRPC handle EKEYEXPIRED in call_refreshresult
  SUNRPC set gss gc_expiry to full lifetime
  SUNRPC new rpc_credops to test credential expiry
  NFS avoid expired credential keys for buffered writes
  SUNRPC refactor rpcauth_checkverf error returns

 fs/nfs/file.c                  |   15 +++++++-
 fs/nfs/internal.h              |    2 +
 fs/nfs/nfs3proc.c              |    6 +-
 fs/nfs/nfs4filelayout.c        |    1 -
 fs/nfs/nfs4proc.c              |   18 --------
 fs/nfs/nfs4state.c             |   23 -----------
 fs/nfs/proc.c                  |   43 --------------------
 fs/nfs/write.c                 |   27 +++++++++++++
 include/linux/sunrpc/auth.h    |   21 ++++++++++
 net/sunrpc/auth.c              |   21 +++++++++-
 net/sunrpc/auth_generic.c      |   84 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/auth_gss.c |   68 ++++++++++++++++++++++++++++----
 net/sunrpc/auth_null.c         |    5 +-
 net/sunrpc/auth_unix.c         |    5 +-
 net/sunrpc/clnt.c              |   18 +++++---
 15 files changed, 248 insertions(+), 109 deletions(-)

-- 
1.7.7.6

