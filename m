Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:38328 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932344Ab2KZXK2 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Nov 2012 18:10:28 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.2 \(1499\))
Subject: Re: [PATCH] Revert "mountd: handle allocation failures in auth_unix_ip upcall"
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20121126225116.GE18186@fieldses.org>
Date: Mon, 26 Nov 2012 18:10:18 -0500
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Message-Id: <EDBFE401-1163-485C-B60E-7D035FD93BB4@oracle.com>
References: <20121126220343.GA18140@fieldses.org> <73EFE585-98D4-40BE-9EDF-15CC6B14BDB2@oracle.com> <20121126221535.GB18186@fieldses.org> <A954A569-E030-4119-A349-6CB888979738@oracle.com> <20121126225116.GE18186@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 26, 2012, at 5:51 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Nov 26, 2012 at 05:38:49PM -0500, Chuck Lever wrote:
>> 
>> On Nov 26, 2012, at 5:15 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>> 
>>> On Mon, Nov 26, 2012 at 05:05:22PM -0500, Chuck Lever wrote:
>>>> 
>>>> On Nov 26, 2012, at 5:03 PM, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>>> 
>>>>> From: "J. Bruce Fields" <bfields@redhat.com>
>>>>> 
>>>>> This reverts commit 485f7a21e1649797f29317b865cbb094c1f6a71d.  The
>>>>> failures handled there could be any sort of name resolution failure, not
>>>>> just an allocation, and failing to downcall (hence leaving the client
>>>>> hanging) is not the correct thing to do in those cases.
>>>> 
>>>> The problem is in the kernel, then: a downcall should be allowed to fail, IMO.
>>> 
>>> In this case, after a revert, a failure here will result in the downcall
>>> passing down a client named "DEFAULT".  Presumably that won't be
>>> permitted access to the export, so the client will end up getting an
>>> error.
>> 
>> "A failure here" can mean either malloc() returned NULL in client_resolve() or client_compose(), or . . . ?
> 
> Looks like it'd also fail if we couldn't map the client's ip address to
> a name.

That's the common failure mode here, which is now treated just like a malloc(3) failure.

>> What exactly is the problem with the current code?

Anyway, it would help my addled brain if the problem description in the next version of this patch was more clear about what the code is doing wrong now.

>> The kernel won't get any downcall reply in that
>> case!  Is that what you are trying to fix?
>> 
>> WRT my original objection: In general I don't see how to make it
>> impossible for mountd to fail.
> 
> Sure, but mountd is required for the server to function, so it's just a
> question of how we fail.
> 
>> Thus the kernel needs to be better about recovering when mountd
>> suddenly disappears.
> 
> Currently it drops and lets the client retry.  I suspect that's the
> correct thing to do, but alternatives are welcomed.

By "drops" do you mean the server drops the NFS request, and the client retransmits the request?  That's actually pretty unfriendly behavior, IMO, since an application on a client is typically stuck at that point until that RPC gets some sort of result (after possibly several RTOs).

Maybe the server could signal an NFS error of some kind and let the client decide if it wants to retry until the server is working again, or fail that request immediately.

(Also, if NFSv4 is dependent on a mountd upcall, it is not supposed to drop a request, AFAIK).

OK, but this is a separate issue from the case you are trying to fix.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



