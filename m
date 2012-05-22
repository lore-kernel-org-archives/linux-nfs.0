Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:23516 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759362Ab2EVP7D convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 May 2012 11:59:03 -0400
Subject: Re: TEST / FREE STATEID error recovery
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=US-ASCII
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4FBB9CB8.5020200@netapp.com>
Date: Tue, 22 May 2012 11:58:58 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <1761A0B6-634E-4E6C-96ED-8E23C13F5EA5@oracle.com>
References: <88F4DB05-5625-4E40-B057-04FCDE21E9C2@oracle.com> <4FBB9AC0.2040102@netapp.com> <379CE82E-0B25-4DCD-A834-A4EF413CA582@oracle.com> <4FBB9CB8.5020200@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 22, 2012, at 10:03 AM, Bryan Schumaker wrote:

> On 05/22/2012 10:02 AM, Chuck Lever wrote:
> 
>> 
>> On May 22, 2012, at 9:55 AM, Bryan Schumaker wrote:
>> 
>>> On 05/21/2012 11:31 PM, Chuck Lever wrote:
>>> 
>>>> Hi-
>>>> 
>>>> I'm trying to understand the error recovery logic in the new TEST_STATEID and FREE_STATEID procedures.
>>>> 
>>>> For TEST_STATEID, we have this:
>>>> 
>>>> 6395 static int nfs41_test_stateid(struct nfs_server *server, nfs4_stateid *stateid)
>>>> 6396 {
>>>> 6397         struct nfs4_exception exception = { };
>>>> 6398         int err;
>>>> 6399         do {
>>>> 6400                 err = nfs4_handle_exception(server,
>>>> 6401                                 _nfs41_test_stateid(server, stateid),
>>>> 6402                                 &exception);
>>>> 6403         } while (exception.retry);
>>>> 6404         return err;
>>>> 6405 }
>>>> 
>>>> According to RFC 5661, the TEST_STATEID and FREE_STATEID procedures can return NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, and NFS4ERR_DEADSESSION, among other things.  Do you really want to enter the exception handler here?  Seems to me that nfs41_{test,free}_stateid() are invoked mainly (only?) by the state manager, and thus you don't want to kick the state manager here and wait, as that would deadlock.  About the only error code you might want to pass into nfs4_handle_exception() is NFS4ERR_DELAY.  Everything else probably ought to be returned outright to the caller to let her figure out how to recover.
>>>> 
>>> 
>>> Sounds about right.  At least passing NFS4ERR_BAD_STATEID will trigger stateid recovery again on the same stateid... probably not what we want.
>>> 
>>>> Also, _nfs41_test_stateid() does this:
>>>> 
>>>> 6390         if (status == NFS_OK)
>>>> 6391                 return res.status;
>>>> 6392         return status;
>>>> 
>>>> status will contain NFS4_OK or a negative NFS4ERR value.  But the "if / return" will return res.status, which could be NFS4_OK, but it could also be (according to RFC 5661 section 18.48.3) NFS4ERR_BAD_STATEID, NFS4ERR_OLD_STATEID, NFS4ERR_EXPIRED, NFS4ERR_ADMIN_REVOKED, or NFS4ERR_DELEG_REVOKED.  Note that these are positive values, and the above logic returns them directly to the caller.
>>>> 
>>> 
>>> So that should be "return -res.status" then?  Easy enough to change.
>>> 
>>>> The caller then passes the positive result to nfs4_handle_exception().  Now I think nfs4_handle_exception() will ignore positive values.  And, I don't see any caller who is not doing "if (status != NFS4_OK)" so maybe this doesn't matter.  But it sure is confusing.
>>>> 
>>> 
>>> This might be why it doesn't deadlock now.
>>> 
>>>> Do you remember what was intended?  Was it positive NFS4ERR values for res.status and negative NFS4ERR values if the operation failed?  If that's the case, then that intention should be carefully documented.  Otherwise, maybe that should read "return -res.status;" (as long as we aren't passing that to the exception handler!).
>>>> 
>>> 
>>> 
>>> My intention was to handle errors coming from the test / free stateid calls.  I didn't realize the RPC call returned a positive value instead of a negative one, so it's only an accident that we don't deadlock now if the server returns NFS4ERR_BAD_STATEID.  This should be fixed though, thanks for catching it!
>> 
>> I've got most of a patch, and a nice test case.  I can wrap this up for you if you like.
> 
> 
> Sure, especially if you've already done most of the work!  Thanks!

OK, if we make these changes, then nfs41_check_expired_stateid() still doesn't make sense:

1741         if (state->flags & flags) {
1742                 status = nfs41_test_stateid(server, stateid);
1743                 if (status != NFS_OK) {
1744                         nfs41_free_stateid(server, stateid);
1745                         state->flags &= ~flags;
1746                 }
1747         }

If nfs41_test_stateid() returns an error, that generally indicates that the server doesn't recognize the state ID, so the client doesn't need to free it.  (But maybe here is where we need to make a careful distinction between a failed state ID test and a successful test that returns BAD_STATEID?).  However, if nfs41_test_stateid() returns NFS4_OK, then the server does recognize the state ID, and the client does need to free it.  So is the above logic backwards?  We have the same logic in nfs41_check_expired_locks().

Also, it seems that during a nograce recovery, nfs4_clear_open_state() clears the state flags that nfs41_check_expired_stateid() uses to decide whether to perform an on-the-wire test.  So nfs41_check_expired_stateid() is always a no-op for nograce recovery, and simply returns NFS4_OK.

Perhaps that's fine, as we don't expect the server to know about this state ID... but maybe it just happens to, and we should check for it anyway?  I think the "state->flags & flags" optimization is probably going to bite us.  We should always check with the server.  Is there harm in doing that?

But when nfs41_check_expired_stateid() returns NFS4_OK, this logic in nfs41_open_expired():

1760         if ((deleg_status == NFS_OK) && (open_status == NFS_OK))
1761                 return NFS_OK;
1762         return nfs4_open_expired(sp, state);

means that nfs4_open_expired() is never invoked, even though, during nograce recovery, we do have a state ID that needs to be recovered.  If we have an open file to recover, shouldn't we try nfs4_open_expired() no matter what?

I'm guessing that the nograce recovery case is not the same as the use cases you were thinking about when you wrote this, so I'm probably not thinking clearly or at all about other uses of this code.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




