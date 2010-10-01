Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:23873 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750814Ab0JAPfH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Oct 2010 11:35:07 -0400
Message-ID: <4CA5FFA9.7090301@panasas.com>
Date: Fri, 01 Oct 2010 17:35:05 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd41: mask out unsupported pnfs attributes
References: <1285872478-21045-1-git-send-email-bhalevy@panasas.com> <20101001144847.GC17310@fieldses.org> <4CA5FB9F.1030508@panasas.com> <20101001152032.GF17310@fieldses.org>
In-Reply-To: <20101001152032.GF17310@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-01 17:20, J. Bruce Fields wrote:
> On Fri, Oct 01, 2010 at 05:17:51PM +0200, Benny Halevy wrote:
>> On 2010-10-01 16:48,  J. Bruce Fields wrote:
>>> On Thu, Sep 30, 2010 at 08:47:58PM +0200, Benny Halevy wrote:
>>>> These attributes are valid in NFSv4.1, the just doesn't support them yet.
>>>
>>> The existing code handles unsupported attributes in the operations
>>> themselves.  Perhaps it makes sense to move those checks here, but if
>>> so, explain why, and let's do this for all unsupported attributes, not
>>> just these two.
>>
>> The client can run a DOS attack on the server by requesting invalid attributes
>> and tripping the BUG_ONs in nfsd4_encode_fattr.
> 
> How can they do that?  getattr and readdir, for example, both handle
> this.  But I may well be missing something!
> 

You're right.  I got confused by the pnfsd specific bug I fixed here:
http://marc.info/?l=linux-nfs&m=128587444310102&w=2

In this case LAYOUT_BLKSIZE was marked as supported but nothing
really supported it so we ended up with an invalid result sent
to the client.

So let's drop this patch. sorry.

Benny

>> We can/should also change the BUG_ONs to either report invalid
>> attribute or just silently ignore them, but the client is
>> perfectly entitled to get attrs we don't support :)
> 
> Sure.
> 
>>> Looking back at the spec....  I guess it's only on operations that set
>>> attributes that we return NFS4ERR_ATTRNOTSUPP, and otherwise we silently
>>> ignore them?
>>
>> For the GETATTR case, we just return the attrmask for the attrs we support.
>> IOW:
>>    The server returns an attribute bitmap that
>>    indicates the attribute values that it was able to return, which will
>>    include all attributes requested by the client that are attributes
>>    supported by the server for the target file system.
> 
> OK, makes sense.
> 
> --b.
