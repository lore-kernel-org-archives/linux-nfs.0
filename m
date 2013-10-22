Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60003 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752351Ab3JVOVW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:21:22 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 0/5] SUNRPC: destroy gss_cred and context on Kerberos credential destruction
Date: Tue, 22 Oct 2013 10:21:11 -0400
Message-ID: <1382451676-2963-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

This patchset requires the nfs-utils "GSSD: Use gss-ctx keys and gsskeyd to
sync Kerber os credentials and kernel gss_contexts" patchset which triggers
gss-ctx key creation on kinit and destruction on kdestroy.

This is an RFC patch set.

We need to do a lot of testing to ensure that
once kdestroy and gss-ctx gss_user_destroy is called, all existing buffered
writes using the 'destroyed gss credential + context' are serviced.

Differences from version1

- Replaced request_key with keyring_search
- Used flag based method to service buffered writes after kdestroy instead
of calling sys_sync.
- Use of the session keyring (KEY_SPEC_USER_SESSION_KEYRING) instead of the user keyring.


Version 1 of these patches were presented along with the GSS expiry patch set.


A new key type, gss-ctx is registered by the auth_gss module. If a gss-ctx 
key is created at kinit (via gsskeyd), the key serial is saved in the resultant
gss_cred. When kdestroy triggers the gss-ctx key destruction (via gsskeyd),
all gss_contexts matching the key-serial are found and the
gss_cred->base (rpc_cred) cr_flags RPCAUTH_CRED_KEY_DESTROYED bit is set.

The new RPC_TASK_BUF_WRITE task flag is set in the NFS layer in
nfs_initiate_write, the buffered write path. Pass the flag to the crmatch
routine via the rpcauth_bindcred lookup_flags.

In gss_match, if the RPCAUTH_CRED_KEY_DESTROYED rpc_cred bit is set and 
if the RPC_TASK_BUF_WRITE flag is set, return found - e.g. use the 
DESTROYED gss_cred for the buffered writes.  Return not-found for all other
calls. The RPC_CRED_KEY_EXPIRE_SOON acred flag is also set which tells the
NFS layer to discontinue any new buffered writes, turning to sync writes
instead. Note that these sync writes will fail as gss_match will find but not
return the DESTROYED gss_cred.

We want to pay close attention to the number of upcalls this code triggers
as a result of the destroyed Kerberos credentials, and destroyed
gss_cred/gss_context.

Andy Adamson (5):
  SUNRPC: register the gss-ctx key type
  SUNRPC set gss_cred gss-ctx key serial
  SUNRPC: invalidate gss_context upon gss-ctx keyring key destruction
  SUNRPC: allow only existing buffered writes on creds with destroyed
    keys
  SUNRPC add EKEYEXPIRED case to call_bind_status

 fs/nfs/write.c                  |   2 +-
 include/linux/sunrpc/auth.h     |   1 +
 include/linux/sunrpc/auth_gss.h |   1 +
 include/linux/sunrpc/sched.h    |   1 +
 net/sunrpc/auth.c               |   2 +
 net/sunrpc/auth_gss/auth_gss.c  | 170 +++++++++++++++++++++++++++++++++++++++-
 net/sunrpc/clnt.c               |   5 ++
 7 files changed, 178 insertions(+), 4 deletions(-)

-- 
1.8.3.1

