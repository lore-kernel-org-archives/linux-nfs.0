From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 6/6] nfs: Fix misparsing of nfsv4 fs_locations attribute
Date: Tue, 10 Jun 2008 16:51:53 -0400
Message-ID: <3086B205-3200-4D77-B4C7-C23163593E37@oracle.com>
References: <1213044696-32741-1-git-send-email-bfields@citi.umich.edu> <1213044696-32741-2-git-send-email-bfields@citi.umich.edu> <1213044696-32741-3-git-send-email-bfields@citi.umich.edu> <1213044696-32741-4-git-send-email-bfields@citi.umich.edu> <1213044696-32741-5-git-send-email-bfields@citi.umich.edu> <1213044696-32741-6-git-send-email-bfields@citi.umich.edu> <1213044696-32741-7-git-send-email-bfields@citi.umich.edu> <1213045696.19130.7.camel@localhost> <20080609212205.GB32446@fieldses.org> <BD59D20E-31F3-4D74-9CB6-3A14F6CB025A@oracle.com> <20080610191752.GN20184@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v924)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:58539 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758196AbYFJUxG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 16:53:06 -0400
In-Reply-To: <20080610191752.GN20184@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 10, 2008, at 3:17 PM, J. Bruce Fields wrote:
> On Tue, Jun 10, 2008 at 11:34:14AM -0400, Chuck Lever wrote:
>> On Jun 9, 2008, at 5:22 PM, J. Bruce Fields wrote:
>>> On Mon, Jun 09, 2008 at 05:08:16PM -0400, Trond Myklebust wrote:
>>>>
>>>> What if it is an IPv6 address? As I've said before, could we please
>>>> just
>>>> adapt nfs_parse_server_address to deal with all these cases?
>>>
>>> I haven't had the time to do that, so I thought we'd rather have a  
>>> fix
>>> for the immediate bug now, then add ipv6 support later.  For all I
>>> know
>>> the final patches might end up factoring reasonable cleanly that way
>>> anyway.
>>
>> I have a patch (upcoming for 2.6.27) that fixes  
>> nfs_parse_server_address
>> to be careful about '\0'-termination.  It changes the function to  
>> take a
>> char * and a length.  All you will need to do is make it non-static.
>
> OK, good.  That patch and my patch will apply together in either  
> order;
> mine ditches the unnecessary valid_ipadd4() and relies on in4_pton()
> instead.  Yours makes nfs_parse_server_address more-or-less a drop-in
> replacement for in4_pton there.  And it should be easy to switch it  
> over
> either in whichever patch comes second or in a small third patch.
>
> So, I was right, this is the natural way to factor out the change
> anyway.
>
> The one remaining thing missing for that to work, I think, is to fix  
> the
>
> 	struct sockaddr *addr;
>
> field in nfs_clone_mount?

"struct sockaddr *" is what we want.  Only the current logic in  
nfs_follow_referral() is AF_INET-specific.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
