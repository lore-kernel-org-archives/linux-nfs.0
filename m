Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:46996 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab3ARW3z convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jan 2013 17:29:55 -0500
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: Question on nfs40_discover_server_trunking.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <50F9C5B4.5020000@candelatech.com>
Date: Fri, 18 Jan 2013 17:29:51 -0500
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <1A56CC87-38FF-47B4-9CA9-7BAE394AF0D2@oracle.com>
References: <50F9BE66.6080608@candelatech.com> <0F001F0E-229D-4314-A42E-84402E4F1FC7@oracle.com> <50F9C5B4.5020000@candelatech.com>
To: Ben Greear <greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 18, 2013, at 4:59 PM, Ben Greear <greearb@candelatech.com> wrote:

> On 01/18/2013 01:33 PM, Chuck Lever wrote:
>> 
>> On Jan 18, 2013, at 4:28 PM, Ben Greear <greearb@candelatech.com> wrote:
>> 
>>> Any chance the STALE_CLIENTID case needs a 'break'?
>> 
>> I don't think so.  LEASE_CONFIRM is set, and we want to wake the state renewal thread.
>> 
>>> 
>>> Twice I've seen kernel crashes after the nfs40_walk_client_list
>>> failed (though code comments say it should never fail).
>> 
>> nfs40_walk_client_list() is looking for an nfs_client that is supposed to already be in the nfs_client list.  If the search fails, that's a bug.
>> 
>> Eyeball the contents of your nfs_client list.  You should find an appropriate nfs_client in there, and then figure out why the search doesn't find it.
> 
> Ok, I think I found another issue.
> 
> nfs4_client_init does not initialize 'old', but passes it to nfs4_discover_server_trunking.
> 
> That gets passed to the detect_trunking operation, which is nfs40_discover_server_trunking
> or nfs41_discover_server_trunking.

Yes, *result is an output parameter, not an input parameter.

> This will call walk_client_list, which also may not ever assign a value to
> 'result'.

It should always assign *result in the SUCCESS case.

> The code in walk_client_list always dereferences result, however.
> 
> So, that is probably why my system blows up shortly after the 'impossible'
> error message...

In particular, nfs4_walk_client_list() does not set *result when it returns NFS4ERR_STALE_CLIENTID.  In nfs4_discover_server_trunking(), should we therefore have this:

     status = nfs40_walk_client_list(clp, result, cred);
     switch (status) {
     case -NFS4ERR_STALE_CLIENTID:
             set_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
>>           nfs4_schedule_state_renewal(clp);
>>           break;
     case 0:

I'm not sure the nfs4_schedule_state_renewal() call is necessary here.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




