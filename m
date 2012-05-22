Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:49058 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758266Ab2EVDb1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 May 2012 23:31:27 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=us-ascii
Subject: TEST / FREE STATEID error recovery
Date: Mon, 21 May 2012 23:31:21 -0400
Message-Id: <88F4DB05-5625-4E40-B057-04FCDE21E9C2@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Bryan Schumaker <bjschuma@netapp.com>
Mime-Version: 1.0 (Apple Message framework v1278)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I'm trying to understand the error recovery logic in the new TEST_STATEID and FREE_STATEID procedures.

For TEST_STATEID, we have this:

6395 static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
6396 {
6397         struct nfs4_exception exception = { };
6398         int err;
6399         do {
6400                 err = nfs4_handle_exception(server,
6401                                 _nfs41_test_stateid(server, stateid),
6402                                 &exception);
6403         } while (exception.retry);
6404         return err;
6405 }

According to RFC 5661, the TEST_STATEID and FREE_STATEID procedures can return NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, and NFS4ERR_DEADSESSION, among other things.  Do you really want to enter the exception handler here?  Seems to me that nfs41_{test,free}_stateid() are invoked mainly (only?) by the state manager, and thus you don't want to kick the state manager here and wait, as that would deadlock.  About the only error code you might want to pass into nfs4_handle_exception() is NFS4ERR_DELAY.  Everything else probably ought to be returned outright to the caller to let her figure out how to recover.

Also, _nfs41_test_stateid() does this:

6390         if (status == NFS_OK)
6391                 return res.status;
6392         return status;

status will contain NFS4_OK or a negative NFS4ERR value.  But the "if / return" will return res.status, which could be NFS4_OK, but it could also be (according to RFC 5661 section 18.48.3) NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, NFS4ERR_EXPIRED, NFS4ERR_ADMIN_REVOKED, or NFS4ERR_DELEG_REVOKED.  Note that these are positive values, and the above logic returns them directly to the caller.

The caller then passes the positive result to nfs4_handle_exception().  Now I think nfs4_handle_exception() will ignore positive values.  And, I don't see any caller who is not doing "if (status != NFS4_OK)" so maybe this doesn't matter.  But it sure is confusing.

Do you remember what was intended?  Was it positive NFS4ERR values for res.status and negative NFS4ERR values if the operation failed?  If that's the case, then that intention should be carefully documented.  Otherwise, maybe that should read "return -res.status;" (as long as we aren't passing that to the exception handler!).

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




