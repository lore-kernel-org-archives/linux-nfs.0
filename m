Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18294 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695AbcEFQnI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 May 2016 12:43:08 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: Configuring NFSv4.0 Kerberos on a multi-homed Linux NFS server
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160506161332.GA11400@fieldses.org>
Date: Fri, 6 May 2016 12:43:03 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <B6BC43C3-2577-4403-B53E-0309866E69EB@oracle.com>
References: <DB5B2D02-412E-46AD-9F0A-7EBA4EB0C0B0@oracle.com> <8198666A-8963-42D2-9C4C-08374F0E8E5D@oracle.com> <20160506024401.GC5365@fieldses.org> <9E194D65-280F-4107-979C-FEFF2B83B211@oracle.com> <20160506161332.GA11400@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On May 6, 2016, at 12:13 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> 
> On Fri, May 06, 2016 at 09:23:40AM -0400, Chuck Lever wrote:
>> 
>>> On May 5, 2016, at 10:44 PM, Bruce Fields <bfields@fieldses.org> wrote:
>>> 
>>> On Thu, May 05, 2016 at 05:01:58PM -0400, Chuck Lever wrote:
>>>> After some IRC discussion with Bruce, we think the answer
>>>> is "this is not supported in the current Linux NFS server."
>>>> 
>>>> The server does not have a way to determine which service
>>>> principal to use for NFSv4.0 callback operations. It picks
>>>> (probably) the first nfs/ service principal in the server's
>>>> keytab for all callback operations.
>>>> 
>>>> Thus if a Linux NFS server has a keytab, clients can mount
>>>> it with NFSv4.0 (and any security flavor) only on the i/f
>>>> whose hostname matches the name of the nfs/ service
>>>> principal in that server's keytab.
>>> 
>>> One correction: the mount should still work correctly.  The server just
>>> won't grant any delegations to the client.
>> 
>> Unfortunately this is not the case.
> 
> Ugh, OK, that's worse than I thought.  I guess you can work around it on
> the server side with "echo 0 >/proc/sys/fs/leases-enable".

Or mount with "clientaddr=0.0.0.0".

So, yes, NFSv4.0 with Kerberos does indeed work in this
situation if delegation / callback is explicitly disabled.


>> The CB_NULLs the server uses to validate the backchannel
>> connection work, and a GSS context is correctly established.
>> The server starts to hand out delegations.
>> 
>> Operation continues until the server tries to recall a
>> delegation. The CB_COMPOUND / CB_RECALL fails for the
>> reasons described above.
>> 
>> Operation stalls for tens of seconds while the server
>> waits for the client to respond to the CB_RECALL.
>> Requests against the file whose delegation is being
>> recalled get NFS4ERR_DELAY.
>> 
>> After some period, the client happens to perform a RENEW,
>> and the server reports NFS4ERR_CB_PATH_DOWN.
>> 
>> The client returns its delegations and performs another
>> SETCLIENTID.
> 
> I wonder why the client does that?  Returning the delegations would seem
> sufficient.

My guess is the client is attempting to clear whatever
problem caused the PATH_DOWN status so the server can
attempt to establish a fresh backchannel connection.


> The other thing the client could do to help would be to at least
> recognize that the principal it gets the NULL call from isn't among the
> principals its going to accept any real callback for.  I think that
> would be easy enough.
> 
> But maybe neither change is justifiable except as a workaround for a
> broken server.
> 
>> The server destroys the backchannel GSS
>> context and closes the backchannel connection.
>> 
>> The server creates a new backchannel connection and
>> establishes a fresh GSS context for the backchannel.
>> Operation continues until the server tries to recall
>> another delegation.
>> 
>> So, operation is correct and no data corruption occurs.
>> But the mount is not usable in any production sense
>> because operation can stall for tens of seconds whenever
>> a delegation recall is attempted. Depending on the
>> workload, that can be frequent, or it may not be
>> noticeable.
>> 
>> This is the behavior when the client discards callback
>> operations that are not properly authenticated. If the
>> client behavior is changed to respond with RPCAUTH_BADCRED,
>> the server can recognize that the client received the
>> request and responded.
>> 
>> The server will have to change its behavior in this case.
>> Today it continues to attempt to use the backchannel, and
>> each attempt fails. Somehow it needs to mark that client
>> so that it stops trying to issue CB operations to it.
> 
> It *should* be marking the callback path down as soon as it knows
> there's a problem (look for nfsd4_mark_cb_down() calls), but in the case
> of an unresponsive client that's always going to take a while.
> 
>>>> In other words, if the server has a keytab with the
>>>> principals:
>>>> 
>>>> nfs/server-a
>>>> nfs/server-b
>>>> nfs/server-c
>>>> 
>>>> NFSv4.0 will operate correctly only when mounting the
>>>> server via server-a: .
>>>> 
>>>> Clients that do not have a keytab should be able to mount
>>>> with NFSv4.0 via the other interfaces. This is because
>>>> they will not try to negotiate krb5i for lease management,
>>>> and the server will not attempt to use krb5i for callback
>>>> operations.
>>>> 
>>>> Bruce feels this is a corner case, would be difficult to
>>>> address, and is adequately worked around by using NFSv3
>>>> or NFSv4.1 or higher. So currently this is a WONTFIX.
>>> 
>>> Right, so if there's somebody really need delegations in the multi-homed
>>> NFSv4.0/krb5 case, they're welcomed to look into it--I can't say I'd
>>> turn down good patches (maybe it's not even that hard--may depend on
>>> whether the gss-proxy protocol does what we need?).  But it doesn't seem
>>> like a priority.
>> 
>> During happy hour, Marcus claimed it should be straightforward
>> to fix.
> 
> OK.

--
Chuck Lever



