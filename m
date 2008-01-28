From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 001/100] nfsd4: probe callback channel only once
Date: Mon, 28 Jan 2008 16:14:47 -0500
Message-ID: <BF917C75-075F-4C6E-AE55-A9DF0D781862@oracle.com>
References: <20080125231521.GG25141@fieldses.org> <1201303040-7779-1-git-send-email-bfields@citi.umich.edu> <68314FDD-D9D1-4DAA-9BC1-423612F05907@oracle.com> <20080128184807.GE16785@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:52638 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbYA1VQy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 16:16:54 -0500
In-Reply-To: <20080128184807.GE16785@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce-

On Jan 28, 2008, at 1:48 PM, J. Bruce Fields wrote:
> On Mon, Jan 28, 2008 at 12:35:48PM -0500, Chuck Lever wrote:
>> On Jan 25, 2008, at 6:15 PM, J. Bruce Fields wrote:
>>> Our callback code doesn't actually handle concurrent attempts to  
>>> probe
>>> the callback channel.  Some rethinking of the locking may be  
>>> required.
>>> However, we can also just move the callback probing to this case.
>>> Since
>>> this is the only time a client is "confirmed" (and since that can  
>>> only
>>> happen once in the lifetime of a client), this ensures we only probe
>>> once.
>>
>> Applying 001/100 without applying 002/100 will probably break
>> bisectability.
>
> You lost me here.  Why?  I'm probably just missing something obvious.


Because, even though the kernel compiles with just 001, it doesn't  
work properly.  In fact, it may even Oops, if I read 002 right, since  
no RPC client is available to do the probe?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
