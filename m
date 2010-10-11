Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18527 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754964Ab0JKQF6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Oct 2010 12:05:58 -0400
Subject: Re: [PATCH 02/15] libnfs.a: Allow multiple RPC listeners to share listener port number
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CB30FA9.8020308@RedHat.com>
Date: Mon, 11 Oct 2010 12:04:50 -0400
Cc: Jim Rees <rees@umich.edu>, linux-nfs@vger.kernel.org
Message-Id: <F750C283-3965-4953-9938-CF049FB914A7@oracle.com>
References: <20101010234836.6667.4057.stgit@ellison.1015granger.net> <20101011000421.6667.60700.stgit@ellison.1015granger.net> <20101011002022.GB25663@merit.edu> <4CB30FA9.8020308@RedHat.com>
To: Steve Dickson <SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Oct 11, 2010, at 9:22 AM, Steve Dickson wrote:

> 
> 
> On 10/10/2010 08:20 PM, Jim Rees wrote:
>> Chuck Lever wrote:
>> 
>>  Normally, when "-p" is not specified on the mountd command line, the
>>  TI-RPC library chooses random port numbers for each listener.  If a
>>  port number _is_ specified on the command line, all the listeners
>>  will get the same port number, so SO_REUSEADDR needs to be set on
>>  each socket.
>> 
>>  Thus we can't let TI-RPC create the listener sockets for us in this
>>  case; we must create them ourselves and then set SO_REUSEADDR (and
>>  other socket options) by hand.
>> 
>> It bothers me that there are two separate code paths in two separate
>> libraries for these two nearly identical cases.

Are there?  Where's the other one?

The two implementations I'm aware of are both in libnfs.a.  One is for legacy RPC, and the other is for TI-RPC, and they both reside in support/nfs/ (and thus in libnfs.a, which is shared by the daemons in nfs-utils).  What am I missing?

>>  Wouldn't it be better to
>> add this functionality to tirpc?
> I have to agree... Why can't we simply had the tirpc code a socket
> that has the SO_REUSEADDR set on it?

I'm not saying absolutely not, but ATM I don't see the utility of doing what you suggest.

TI-RPC has a more-or-less standard API across O/S implementations.  I would think we should avoid making Linux-specific changes to the API, as that would limit the portability of RPC applications on Linux.  That's why I think this kind of thing belongs in nfs-utils, and not in TI-RPC.  If we put this code into TI-RPC, would we also need to do the same for the legacy glibc RPC implementation?

Secondly, SO_REUSEADDR is only half the fix.  The other half is xprt caching.  Simply changing the library to set SO_REUSEADDR is going to help only the case where the application wants just one version (eg, just MNT v1).

Creating a socket and passing it to svc_tli_create(3t) is exactly how the library was intended to be used in this case.  This is how rpcbind works, for instance, which suggests to me that anyone familiar with RPC servers will recognize this code idiom for what it is.

The Sun ONC+ documentation also recommends the use of svc_tli_create(3t) when an application needs to pass in a socket or specify a bind address.  This is referred to as the "expert" level server-side interface, which suggests this is going to be used rarely and only in special situations.

Can you suggest an API change to TI-RPC that would allow server applications to request an internally created socket with SO_REUSEADDR set?

-- 
chuck[dot]lever[at]oracle[dot]com




