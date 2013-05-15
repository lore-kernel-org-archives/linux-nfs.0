Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:17533 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758912Ab3EOQrS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 May 2013 12:47:18 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: [PATCH 0/2] [RFC] Maybe avoid gssd upcall timeout
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1368636039.3568.13.camel@leira.trondhjem.org>
Date: Wed, 15 May 2013 12:47:13 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <60ACCEE3-E1EA-49EA-8D14-C1AAB658F7D0@oracle.com>
References: <20130513161515.1942.845.stgit@seurat.1015granger.net> <1368634683.3568.5.camel@leira.trondhjem.org> <13B2D107-E7C3-4AF8-B205-7BF1304DFF25@oracle.com> <1368635073.3568.7.camel@leira.trondhjem.org> <5E95E534-4C1A-4AF5-B0CD-240EB5592E96@oracle.com> <1368636039.3568.13.camel@leira.trondhjem.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 15, 2013, at 12:40 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Wed, 2013-05-15 at 12:30 -0400, Chuck Lever wrote:
>> On May 15, 2013, at 12:24 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>> 
>>> On Wed, 2013-05-15 at 12:22 -0400, Chuck Lever wrote:
>>>> On May 15, 2013, at 12:18 PM, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>> 
>>>>> On Mon, 2013-05-13 at 12:25 -0400, Chuck Lever wrote:
>>>>>> Hi-
>>>>>> 
>>>>>> Here's a stab at addressing the 15 second wait for some 3.10 sec=sys
>>>>>> mounts where the client is not running rpc.gssd.
>>>>>> 
>>>>>> After reverting the "use krb5i for SETCLIENTID" patch, I've added
>>>>>> the AUTH_SYS fallback in the EACCES case in
>>>>>> nfs4_discover_server_trunking().  I'm not sure whether we need to
>>>>>> supplement what's there now, or replace it.
>>>>>> 
>>>>>> "case -ENOKEY:" is added so the kernel will recognize that when gssd
>>>>>> is changed to return that instead of EACCES in this case.  If the
>>>>>> second patch is appled to 3.7 stable and following, it might be a way
>>>>>> to address the same regression in older kernels.
>>>>>> 
>>>>>> I've been focused on another bug this week, so this has seen very
>>>>>> light testing only.  Looking for comments.
>>>>> 
>>>>> I'd like to propose a different approach: we can set up rpc_pipefs files
>>>>> clnt/gssd and clnt/krb5 as "honeypots" that rpc.gssd will connect to,
>>>>> but that won't do any upcalls. When gssd connects, we set a
>>>>> per-rpc_net_ns variable that tells us 'gssd' is up and running. That
>>>>> variable only gets cleared if we see a timeout.
>>>> 
>>>> Note my solution is a short term gap filler.  Bruce and Jeff seem to want something that can fix current kernels without requiring user space changes, and I need something that will allow sec=krb5 mounts to work without a client keytab on kernels since 3.7.
>>>> 
>>>> I see your proposal as a long term fix, and not something that we can expect to apply without deploying gssd support at the same time.
>>> 
>>> How does it require gssd modifications?
>>> 
>>> The whole point is that it requires kernel-only changes, and only minor
>>> changes at that...
>> 
>> You'll have to be more specific then.  The impression I was left with last week was that this solution was a non-starter because one of the two end points wipes all the directories at certain times.
>> 
> No. The problem was the gssd behaviour when it receives a directory
> notification due to a client creation/destroy event: it disconnects from
> all rpc pipes, and then reconnects to them.
> 
> That is solved by using the strategy that the variable is set on the
> first connection by gssd, and is only cleared if we see a timeout. It
> means that we can quickly detect whether or not gssd has been started
> (which is what we need here).

It seems to me we want to leave that per-ns flag set.  An upcall timeout can result even when gssd is running, so should we consider a timeout reason to clear the flag?

Are you trying to detect the case where gssd was started but then is stopped (due to administrative action or daemon crash)?



-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




