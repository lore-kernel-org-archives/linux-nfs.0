Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21337 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758125Ab2IJUJB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Sep 2012 16:09:01 -0400
Date: Mon, 10 Sep 2012 16:08:58 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/4] RFC Avoid expired credential keys for buffered
 writes
Message-ID: <20120910160858.552bec1b@corrin.poochiereds.net>
In-Reply-To: <7851A663D3BF5E41B9E166C2C7A42145102B2F5A@SACEXCMBX02-PRD.hq.netapp.com>
References: <1346961251-2554-1-git-send-email-andros@netapp.com>
	<20120910145732.4d800f5b@corrin.poochiereds.net>
	<7851A663D3BF5E41B9E166C2C7A42145102B2F5A@SACEXCMBX02-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 10 Sep 2012 19:52:35 +0000
"Adamson, Andy" <William.Adamson@netapp.com> wrote:

> 
> On Sep 10, 2012, at 2:57 PM, Jeff Layton wrote:
> 
> > On Thu,  6 Sep 2012 15:54:07 -0400
> > andros@netapp.com wrote:
> > 
> >> From: Andy Adamson <andros@netapp.com>
> >> 
> >> This patch set is a Request for Comments: I think it does a fair job of
> >> handling the issue - but it is complicated, and other brains might find a
> >> better way to get the job done.
> >> 
> >> We must avoid buffering a WRITE that is using a credential key (e.g. a GSS
> >> context key) that is about to expire or has expired.  We currently will
> >> paint ourselves into a corner by returning success to the applciation
> >> for such a buffered WRITE, only to discover that we do not have permission when
> >> we attempt to flush the WRITE (and potentially associated COMMIT) to disk.
> >> This results in data corruption.
> >> 
> >> First, a couple of "setup" patches:
> >> 1) Patch SUNRPC handle EKEYEXPIRED in call_refreshresult returns EACCES to the
> >> application on an expired or non-existent gss context when the users (Kerberos)
> >> credentials have also expired or are non-existent. Current behavior is to
> >> retry upcalls to GSSD forever. Please see patch comment for detail.
> >> 
> >> 2) Patch SUNRPC set gss gc_expiry to full lifetime works in conjunction with
> >> the gssd patch "0001-GSSD-Pass-GSS_context-lifetime-to-the-kernel". The
> >> gssd patch passes the actual remaining TGT lifetime in the downcall, and
> >> this kernel patch sets the gss context gc_expiry to this lifetime.
> >> 
> >> Then the two patches that avoid using an expired credential key:
> >> 3) Patch SUNRPC new rpc_credops to test credential expiry is the heart of this
> >> work. It provides the RPC layer helper functions to allow NFS to manage
> >> data in the face of expired credentials
> >> 
> >> 4) Patch NFS avoid expired credential keys for buffered writes calls the
> >> RPC helper functions.
> >> 
> >> Pages for buffered WRITEs are allocated in nfs_write_begin where we have an
> >> nfs_open_context and associated rpc_cred. This is a generic rpc_cred, NOT
> >> the gss_cred used in the actual WRITE RPC. Each WRITE RPC call takes the generic
> >> rpc_cred (or uses the 'current_cred') uid and uses it to lookup the associated
> >> gss_cred and gss_context in the call_refresh RPC state. So, there is a
> >> one-to-one association between the nfs_open_context generic_cred and a
> >> gss_cred with a matching uid and a valid non expired gss context.
> >> 
> >> We need to check the nfs_open_context generic cred 'underlying' gss_cred
> >> gss_context gc_expiry in nfs_write_begin to determine if there is enough time
> >> left in the gss_context lifetime to complete the buffered WRITE.
> >> 
> >> I started by adding a "key_timeout" rpc_authops routine only set by the generic
> >> auth to do this work, called by rpcauth_key_timeout_notify, called from
> >> nfs_write_begin. It does the lookup of the gss_cred (see the patch for
> >> fast-tracking of non-gss underlying creds) and then tests the gss_context
> >> gc_expiry against timeouts by calling a new crkey_timeout rpc_credops set
> >> only for the gss_cred.
> >> 
> >> I came up with the idea of two credential key timeout watermarks:
> >> 1) A high watermark, RPC_KEY_EXPIRE_TIMEO set to 90 seconds.
> >> 2) A low watermark, RPC_KEY_EXPIRE_FAIL set to 30 seconds.
> >> NOTE: these timeouts are guesses that work in a VM environment. We may want to
> >> make them adjustable via module parameters.
> >> 
> >> If key_timeout is called on a credential with an underlying credential key that
> >> will expire within high watermark seconds, we set the RPC_CRED_KEY_EXPIRE_SOON
> >> flag in the generic_cred acred so that the NFS layer can clean up prior to
> >> key expiration It does this by calling a new crkey_to_expire rpc_credop set
> >> only for generic creds that tests for the RPC_CRED_KEY_EXPIRE_SOON flag.
> >> 
> >> If the RPC_CRED_KEY_EXPIRE_SOON flag is set in the nfs_open_context generic
> >> cred (the acred portion), then nfs_write_end will call nfs_wb_all
> >> on EVERY WRITE CALL it sees, and nfs_write_rpcsetup will send NFS_FILE_SYNC
> >> WRITEs.  The idea of the high watermark is to give time to flush all buffered
> >> WRITEs and COMMITs, as well as to continue to WRITE, but only with
> >> NFS_FILE_SYNC, allowing the application to try to finish writing before the
> >> gss context expires. NOTE that this means EACH WRITE within the high watermark
> >> timeout is a singe PAGE of NFS_FILE_SYNC. I think this is fine, because we are
> >> in a failure mode - the most important thing is to NOT fail a buffered WRITE..
> >> 
> >> If key_timeout is called on a credential key that will expire within low
> >> watermark seconds, we return EACCES from nfs_write_begin to stop
> >> the buffered WRITE using the credential key.
> >> 
> >> Checking a generic credential's underlying credential involves a cred lookup.
> >> To avoid this lookup in the normal case when the underlying credential has
> >> a key that is valid (before the high watermark), a notify flag is set in
> >> the generic credential the first time the key_timeout is called. The
> >> generic credential then stops checking the underlying credential key expiry, and
> >> the underlying credential (gss_cred) match routine then checks the key
> >> expiration upon each normal use and sets a flag in the associated generic
> >> credential only when the key expiration is within the high watermark.
> >> This in turn signals the generic credential key_timeout to perform the extra
> >> credetial lookup thereafter.
> >> 
> >> TING:
> >> 
> >> I have tested these patches with a TGT of 5 minutes, and a modified
> >> Connectathon special test: bigfile.c that only writes and never flushes.
> >> I also increased the file size to 524288000 bytes to give me time.
> >> I named the test buffered-write.
> >> 
> >> I kinit, and run 6 instances of buffered write with the first and maybe second
> >> test completing prior to TGT expiration, and the third/fourth tests spanning
> >> the high water mark. The fifth test starts within the high water mark, and the
> >> sixth test starts within the low water mark.
> >> 
> >> I have seen the expected behavior: test 1,2 succeed. Tests 3-6 fail with
> >> Permission Denied. Tests 3 and 4 start with normal buffered UNSTABLE writes
> >> then switch to single page NFS_FILE_SYNC writes with a COMMIT for the
> >> normal buffered writes. Test 5 has only single page NFS_FILE_SYNC writes,
> >> test 6 simply fails.
> >> 
> >> None of the WRITEs fail.
> >> 
> >> ISSUES
> >> 1) Once in a while I see "short write" instead of "Permission
> >> denied". I cannot reproduce this. Even then wireshark shows all writes succeeding.
> >> 
> >> 2) Although I have tested re-establishing Kerberos credentials after the
> >> test run, I have not done any testing re-estabishing Kerberos credentials 
> >> during the a test run that is within the high watermark.
> >> 
> >> 3) General corner case and other testing
> >> 
> >> -->Andy
> >> 
> >> Andy Adamson (4):
> >>  SUNRPC handle EKEYEXPIRED in call_refreshresult
> >>  SUNRPC set gss gc_expiry to full lifetime
> >>  SUNRPC new rpc_credops to test credential expiry
> >>  NFS avoid expired credential keys for buffered writes
> >> 
> >> fs/nfs/file.c                  |   10 ++++
> >> fs/nfs/internal.h              |    2 +
> >> fs/nfs/nfs3proc.c              |    6 +-
> >> fs/nfs/nfs4filelayout.c        |    1 -
> >> fs/nfs/nfs4proc.c              |   18 --------
> >> fs/nfs/nfs4state.c             |   22 ---------
> >> fs/nfs/proc.c                  |   43 ------------------
> >> fs/nfs/write.c                 |   29 ++++++++++++
> >> include/linux/sunrpc/auth.h    |   27 ++++++++++++
> >> net/sunrpc/auth.c              |   21 +++++++++
> >> net/sunrpc/auth_generic.c      |   93 ++++++++++++++++++++++++++++++++++++++++
> >> net/sunrpc/auth_gss/auth_gss.c |   51 +++++++++++++++++++---
> >> net/sunrpc/clnt.c              |    1 +
> >> 13 files changed, 231 insertions(+), 93 deletions(-)
> >> 
> > 
> > In general, I like this set...
> > 
> > My only concern is this behavior described in the last patch:
> > 
> > "If the buffered WRITE is using a credential key that will expire
> > within low watermark seconds, fail the WRITE in nfs_write_begin
> > _before_ the WRITE is buffered and return -EACCES to the application."
> > 
> > Shouldn't rejecting the write attempt be the purview of the server?
> 
> The TGT lifetime is shared by the client and the server - it's the same, so I don't think we'd gain anything by doing that.
> 
> > 
> > It seems to me that we'd be best off just switching to synchronous
> > writes when we start approaching credential expiration, and letting the
> > server handle the case where the credential expires.
> 
> You mean switching to direct IO? I believe that means taking a different path in the VFS layer which I found difficult to do from nfs_write_begin. But maybe I just didn't see a good way to do this.
> 
> 
> > It seems to me that the client should just be in the business of
> > recognizing when the credential might be about to expire and attempt to
> > ensure that we don't end up with a bunch of buffered data in that case.
> 
> Yes.
> 
> -->Andy
> 
> > 
> > -- 
> > Jeff Layton <jlayton@redhat.com>
> 


I meant that I didn't really see the point of the two different states
when we're approaching ticket expiry.

IIUC, at the "high watermark", you'll switch to synchronous writes, and
presumably will start syncing out any buffered data. At that point,
what are you buying by rejecting writes altogether with EACCES at the
low watermark?

It seems to me that the high watermark should be all you need to deal
with as a client. Once you're past that point you can just let the
client attempt the writes. If they fail, then no big deal -- you were
doing synchronous writes already so you've already avoided having a
bunch of data buffered up.

-- 
Jeff Layton <jlayton@redhat.com>
