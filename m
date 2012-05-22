Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:22737 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752889Ab2EVOCK convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 10:02:10 -0400
Subject: Re: TEST / FREE STATEID error recovery
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FBB9AC0.2040102@netapp.com>
Date: Tue, 22 May 2012 10:02:04 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <379CE82E-0B25-4DCD-A834-A4EF413CA582@oracle.com>
References: <88F4DB05-5625-4E40-B057-04FCDE21E9C2@oracle.com> <4FBB9AC0.2040102@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 22, 2012, at 9:55 AM, Bryan Schumaker wrote:

> On 05/21/2012 11:31 PM, Chuck Lever wrote:
> 
>> Hi-
>> 
>> I'm trying to understand the error recovery logic in the new TEST_STATEID and FREE_STATEID procedures.
>> 
>> For TEST_STATEID, we have this:
>> 
>> 6395 static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
>> 6396 {
>> 6397         struct nfs4_exception exception = { };
>> 6398         int err;
>> 6399         do {
>> 6400                 err = nfs4_handle_exception(server,
>> 6401                                 _nfs41_test_stateid(server, stateid),
>> 6402                                 &exception);
>> 6403         } while (exception.retry);
>> 6404         return err;
>> 6405 }
>> 
>> According to RFC 5661, the TEST_STATEID and FREE_STATEID procedures can return NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, and NFS4ERR_DEADSESSION, among other things.  Do you really want to enter the exception handler here?  Seems to me that nfs41_{test,free}_stateid() are invoked mainly (only?) by the state manager, and thus you don't want to kick the state manager here and wait, as that would deadlock.  About the only error code you might want to pass into nfs4_handle_exception() is NFS4ERR_DELAY.  Everything else probably ought to be returned outright to the caller to let her figure out how to recover.
>> 
> 
> Sounds about right.  At least passing NFS4ERR_BAD_STATEID will trigger stateid recovery again on the same stateid... probably not what we want.
> 
>> Also, _nfs41_test_stateid() does this:
>> 
>> 6390         if (status == NFS_OK)
>> 6391                 return res.status;
>> 6392         return status;
>> 
>> status will contain NFS4_OK or a negative NFS4ERR value.  But the "if / return" will return res.status, which could be NFS4_OK, but it could also be (according to RFC 5661 section 18.48.3) NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, NFS4ERR_EXPIRED, NFS4ERR_ADMIN_REVOKED, or NFS4ERR_DELEG_REVOKED.  Note that these are positive values, and the above logic returns them directly to the caller.
>> 
> 
> So that should be "return -res.status" then?  Easy enough to change.
> 
>> The caller then passes the positive result to nfs4_handle_exception().  Now I think nfs4_handle_exception() will ignore positive values.  And, I don't see any caller who is not doing "if (status != NFS4_OK)" so maybe this doesn't matter.  But it sure is confusing.
>> 
> 
> This might be why it doesn't deadlock now.
> 
>> Do you remember what was intended?  Was it positive NFS4ERR values for res.status and negative NFS4ERR values if the operation failed?  If that's the case, then that intention should be carefully documented.  Otherwise, maybe that should read "return -res.status;" (as long as we aren't passing that to the exception handler!).
>> 
> 
> 
> My intention was to handle errors coming from the test / free stateid calls.  I didn't realize the RPC call returned a positive value instead of a negative one, so it's only an accident that we don't deadlock now if the server returns NFS4ERR_BAD_STATEID.  This should be fixed though, thanks for catching it!

I've got most of a patch, and a nice test case.  I can wrap this up for you if you like.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




