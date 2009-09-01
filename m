From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Change default behavior when "sec=" is not specified by user
Date: Tue, 1 Sep 2009 16:31:54 -0400
Message-ID: <411DA127-278F-4799-9E40-EB8409510E2E@oracle.com>
References: <20090901151830.GC22846@fieldses.org> <18678BB3-52C6-4376-BBD1-50B8947BAAC7@oracle.com> <20090901160914.GG22846@fieldses.org> <73E8EAAF-9164-4F78-A9D4-1CC86A6A6255@oracle.com> <20090901163846.GJ22846@fieldses.org> <B9CADBA9-54B0-44AD-A8DC-FE3ED63341BC@oracle.com> <1251829540.18608.31.camel@heimdal.trondhjem.org> <D11105A9-4FAB-4F5C-BF02-BE489520C150@oracle.com> <1251833479.18608.69.camel@heimdal.trondhjem.org> <E7FCF468-0A25-4DA1-8E71-A383BCBA4642@oracle.com> <20090901201544.GF27726@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:18165 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753933AbZIAUcJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 16:32:09 -0400
In-Reply-To: <20090901201544.GF27726@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 1, 2009, at 4:15 PM, J. Bruce Fields wrote:
> On Tue, Sep 01, 2009 at 04:10:57PM -0400, Chuck Lever wrote:
>> On Sep 1, 2009, at 3:31 PM, Trond Myklebust wrote:
>>> As I said, this functionality is in also required in order to make
>>> NFSv4
>>> security negotiation work.
>>
>> This is all added to the kernel's MNT client.  None of this logic  
>> will
>> ever be used by NFSv4, unless we refactor it someday.  At which  
>> time, we
>> can worry about it then.
>>
>>> ...and for NFSv2 as well...
>>
>> Now you've lost me.  The v1 MNTPROC doesn't return a flavor list, so
>> NFSv2 doesn't support security flavor negotiation at mount time.
>
> The protocol doesn't have explicit support for it, just as NFSv4.0
> doesn't in the case of security on /, but we can still support a  
> form of
> "negotiation" in both cases by doing a linear search through the
> supported flavors and trying each one.
>
> I agree that we should do that.  I don't think it necessarily needs to
> be done *before* any of the other changes that have been discussed, so
> it could be done as a second step.

For v4, you have WRONGSEC, but I don't think NFSv2 makes that  
distinction.  Would the client probe the server with NFS requests each  
using a different flavor?  Would we expect to see the RPC level "weak  
authentication" reply in the NFSv2 case?  Before Eisler says it, why  
would we bother?

Even so, that's a much different proposition than simply reading the  
flavor list returned by MNT3PROC, so I'm straining to see how we could  
reuse the logic I'm adding to the kernel's MNT client to do security  
negotiation for NFSv2.  If Trond is referring only to merging the  
kernel's auth flavor lists, then that comment makes more sense.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



