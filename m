Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:39885 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757958Ab2FZALI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jun 2012 20:11:08 -0400
Subject: Re: [PATCH] NFS: Handle authentication errors correctly during lease reclaim
Mime-Version: 1.0 (Apple Message framework v1278)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1340663037.9620.77.camel@lade.trondhjem.org>
Date: Mon, 25 Jun 2012 20:11:02 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <C7E3A1AE-CD23-4E7F-B7F3-699DCE35BCCF@oracle.com>
References: <20120625204637.1637.14358.stgit@degas.1015granger.net> <1340659210.9620.64.camel@lade.trondhjem.org> <80FBF1AB-7347-4683-9F4E-8FD489641EE0@oracle.com> <1340663037.9620.77.camel@lade.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 25, 2012, at 6:24 PM, Myklebust, Trond wrote:

> On Mon, 2012-06-25 at 17:32 -0400, Chuck Lever wrote:
>> On Jun 25, 2012, at 5:20 PM, Myklebust, Trond wrote:
>> 
>>> On Mon, 2012-06-25 at 16:47 -0400, Chuck Lever wrote:
>>>> Commit 2a6ee6aa "NFSv4: Clean up the error handling for
>>>> nfs4_reclaim_lease" May 25, 2012 appears to have changed the error
>>>> value returned by nfs4_reclaim_lease() if rpc.gssd fails to create
>>>> a machine credential (either due to a local error or a problem on
>>>> the server).
>>> 
>>> It is _not_ an error to be mounting without machine credentials.
>> 
>> Correct, and the client shouldn't oops in this case either.
>> 
>>>> In this case, nfs4_proc_setclientid() returns -EACCES.  Before
>>>> 2a6ee6aa, nfs4_reclaim_lease() converted this to -EAGAIN.  Now it
>>>> returns zero.  The state manager assumes all is well, nfs_client
>>>> initialization then proceeds in process context until it oopses while
>>>> trying to set up the mount's nfs_server.
>>> 
>>> The PURGE_STATE and/or LEASE_EXPIRED flags should still be set if we
>>> exit via nfs4_handle_reclaim_lease_error. The zero error return is there
>>> in order to ensure that the state manager thread loops and retries
>>> instead of just aborting.
>> 
>> My test case is attempting to mount a server with "sec=krb5" explicitly set.  The server was not configured correctly.  Why should the client retry in this case?  There's nothing it can do to correct this situation.
>> 
>> (Not to mention the fact that the gssd error messages on the client are incredibly obtuse and unhelpful).
>> 
>>> This patch makes it impossible to run without machine creds because you
>>> circumvent the nfs4_clear_machine_cred()+retry case.
>> 
>> Perhaps that's incorrect, but it's what the code used to do before 2a6ee6aa, as near as I can tell.
> 
> Reverting to a broken previous state isn't really all that useful.

My point was that the patch description did not suggest you were fixing a problem with mounting without machine creds.  That's why I thought reverting that logic would be acceptable.

The change to return 0 makes sense now, but I don't understand why you changed the "if (cred == clp->cl_machine_cred)" logic.  That still seems wrong.  In any event, maybe that patch is doing too many changes at once and should have been split apart.

> Can you please send me a copy of the Oops that you are seeing?

Tell you what, tomorrow I'll remove the UCS patches and try to reproduce this, then we can go from there.  This may be a problem solely with trunking discovery, but if not, taking these new patches out of the picture will help.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




