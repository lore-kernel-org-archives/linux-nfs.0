Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41500 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756225Ab3BTRFS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Feb 2013 12:05:18 -0500
Content-Type: text/plain; charset=iso-8859-1
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: synchronous AF_LOCAL connect
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20130220163424.GK14606@fieldses.org>
Date: Wed, 20 Feb 2013 12:04:59 -0500
Cc: Trond Myklebust <trond@netapp.com>, linux-nfs@vger.kernel.org,
        simo@redhat.com
Message-Id: <FB21B277-FA7D-490C-B389-58A91C46B490@oracle.com>
References: <20130218225424.GD3391@fieldses.org> <20130220154751.GH14606@fieldses.org> <2F275139-9861-4414-8C9F-BD74544C9AD7@oracle.com> <20130220160350.GJ14606@fieldses.org> <EA9EE56A-73BB-4866-AA86-1EE4150AFE87@oracle.com> <20130220163424.GK14606@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Feb 20, 2013, at 11:34 AM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Wed, Feb 20, 2013 at 11:20:05AM -0500, Chuck Lever wrote:
>> 
>> On Feb 20, 2013, at 11:03 AM, J. Bruce Fields <bfields@fieldses.org>
>> wrote:
>> 
>>> On Wed, Feb 20, 2013 at 10:56:54AM -0500, Chuck Lever wrote:
>>>> 
>>>> On Feb 20, 2013, at 10:47 AM, "J. Bruce Fields"
>>>> <bfields@fieldses.org> wrote:
>>>> 
>>>>> On Mon, Feb 18, 2013 at 05:54:25PM -0500, bfields wrote:
>>>>>> The rpc code expects all connects to be done asynchronously by a
>>>>>> workqueue.  But that doesn't seem necessary in the AF_LOCAL case.
>>>>>> The only user (rpcbind) actually wants the connect done in the
>>>>>> context of a process with the right namespace.  (And that will be
>>>>>> true of gss proxy too, which also wants to use AF_LOCAL.)
>>>>>> 
>>>>>> But maybe I'm missing something.
>>>>>> 
>>>>>> Also, I haven't really tried to understand this code--I just
>>>>>> assumed I could basically call xs_local_setup_socket from ->setup
>>>>>> instead of the workqueue, and that seems to work based on a very
>>>>>> superficial test.  At a minimum I guess the PF_FSTRANS fiddling
>>>>>> shouldn't be there.
>>>>> 
>>>>> Here it is with that and the other extraneous xprt stuff gone.
>>>>> 
>>>>> See any problem with doing this?
>>>> 
>>>> Nothing is screaming at me.  As long as an AF_LOCAL connect
>>>> operation doesn't ever sleep, this should be safe, I think.
>>> 
>>> I'm sure it must sleep.  Why would that make any difference?
>> 
>> As I understand it, sometimes an ASYNC RPC task is driving the
>> connect, and such a task must never sleep when calling outside of
>> rpciod.
> 
> AF_LOCAL is currently only used to register rpc services.  I can't see
> any case when it's called asynchronously.
> 
> (And the same will be true of the gss-proxy calls, which also plan to
> use AF_LOCAL.)

Yes, but AF_LOCAL is supposed to be a generic transport for RPC.  This is not a feature we just made up, it's actually a well-defined API that exists on other platforms (it's even specified in RFCs).  Right now I would hesitate to restrict the use of AF_LOCAL upcalls to only synchronous contexts, because eventually we may want to use the transport in asynchronous contexts.

If we were to go with using a synchronous connect, however, I think there should be some kind of safety check to make sure the xs connect function is not being invoked from an asynchronous context.  This is a restriction that does not exist for other transports supported by the kernel RPC client, so it should be underscored in the code.

Alternately, perhaps your new code could continue to invoke the kernel connect operation in a non-blocking mode, and simply have the local transport setup function fail if the non-blocking connect operation does not return with success.  That would be an interesting test to see if an AF_LOCAL connect operation actually does try to sleep in common code paths.


> 
>> rpciod must be allowed to put that task on a wait queue and
>> go do other work if the connect operation doesn't succeed immediately,
>> otherwise all ASYNC RPC operations hang (or worse, an oops occurs).
>> 
>>>> How did you test it?
>>> 
>>> I'm just doing my usual set of connectathon runs, and assuming mounts
>>> would fail if the server's rpcbind registration failed.
>> 
>> Have you tried killing rpcbind first to see how the error cases are handled?
> 
> No, thanks for the suggestion, I'll check.
> 
>> Does rpcbind get the registration's "owner" field correct when
>> namespaces are involved?
> 
> Looking at rpcb_clnt.c....  I only ever see r_owner set to "" or "0".  I
> can't see why that would need to change in a container.

rpcbind scrapes the remote end of the socket to see who's calling.  IIRC the r_owner field is ignored if it's not root who is making the registration request.

This is the raison d'être to register RPC services via AF_LOCAL transports.  Thus it should be explicitly tested that rpcbind gets registration correct after changes are made to AF_LOCAL support in the kernel's RPC client.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




