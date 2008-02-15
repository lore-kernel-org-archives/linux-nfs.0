From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/2] NLM failover unlock
Date: Fri, 15 Feb 2008 11:36:59 -0500
Message-ID: <20080215163659.GD20826@fieldses.org>
References: <4781B91D.8090509@redhat.com> <20080214183833.GA26936@newbie.thebellsplace.net> <47B490BC.2000309@netapp.com> <20080215162022.GA20826@fieldses.org> <755EF02D-A01D-409C-B695-E26F9A4A22BF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wendy Cheng <wcheng@netapp.com>,
	Bob Bell <b_linuxnfs-Y/+76LoPTq9wBoktGHYdvgC/G2K4zDHf@public.gmane.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:49063 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025AbYBOQhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Feb 2008 11:37:03 -0500
In-Reply-To: <755EF02D-A01D-409C-B695-E26F9A4A22BF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 15, 2008 at 11:30:04AM -0500, Chuck Lever wrote:
> On Feb 15, 2008, at 11:20 AM, J. Bruce Fields wrote:
>> On Thu, Feb 14, 2008 at 02:04:28PM -0500, Wendy Cheng wrote:
>>> Bob Bell wrote:
>>>> On Mon, Jan 07, 2008 at 12:31:09AM -0500, Wendy Cheng wrote:
>>>>> This submission is part of the patch sets added to support NFS  
>>>>> server
>>>>> failover where the specified export is moved from one physical  
>>>>> server
>>>>> to another.
>>>>
>>>> Wendy,
>>>>
>>>> What's the current status of these patches?  I believe I have a
>>>> situation that could benefit from being able to release all NLM  
>>>> locks
>>>> on an exported filesystem.
>>>>
>>> I think Bruce has queued the unlock patch for 2.6.26 (Bruce ?) ..
>>
>> Not yet, for several reasons.  First, there's two smaller problems
>> outstanding that I can recall:
>>
>> 	- We should be matching on the superblock, not the vfs mount.
>> 	  Otherwise, for example, the unlock will have no effect if it's
>> 	  done from a private namespace, which I think will be
>> 	  unexpected.  Arguably this could result in revoking more locks
>> 	  than necessary, but if the goal is to allow unmounting some
>> 	  shared block device, then that's what we've got to do.
>> 	- Let's get the address types right.  I think the concensus from
>> 	  previous discussions was just to use in6_addr everywhere?
>
> I thought the consensus was use in_addr everywhere, and let me worry  
> about converting these to in6_addr as part of the NLM IPv6 work.

OK, that'd be fine too.

--b.
