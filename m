From: Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: [PATCH] lockd: unlock lockd locks held for a certain filesystem
Date: Wed, 23 Apr 2008 17:44:48 -0400
Message-ID: <480FADD0.90200@gmail.com>
References: <4808A9DE.9040304@gmail.com> <20080418181918.GB24552@fieldses.org> <20080422231520.GI21770@fieldses.org> <20080422231729.GJ21770@fieldses.org> <20080422231855.GK21770@fieldses.org> <20080423074422.GA23518@lst.de> <20080423171240.GG31576@fieldses.org> <480F9E6F.4070204@gmail.com> <20080423210227.GF8302@fieldses.org> <480FA769.40900@gmail.com> <20080423213918.GH8302@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Christoph Hellwig <hch@lst.de>, nfs@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, Lon Hohberger <lhh@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:25081 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751926AbYDWVmx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2008 17:42:53 -0400
In-Reply-To: <20080423213918.GH8302@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Wed, Apr 23, 2008 at 05:17:29PM -0400, Wendy Cheng wrote:
>   
>> J. Bruce Fields wrote:
>>     
>>> On Wed, Apr 23, 2008 at 04:39:11PM -0400, Wendy Cheng wrote:
>>>   
>>>       
>>>> #if defined(BRUCE_CHECK_THIS_OUT)
>>>> error = nlmsvc_failover_path(nd.path.mnt->mnt_sb);
>>>> #else
>>>> error = nlmsvc_failover_path(nd.mnt->mnt_sb);
>>>> #endif
>>>>     
>>>>         
>>> The vfsmount and dentry got moved into the path argument sometime in the
>>> last kernel version or so.  Is there a macro defining the latter as a
>>> shortcut for the former?  I didn't see one.
>>>
>>>
>>>   
>>>       
>> Sorry, just realized my kernel is too old (2.6.25)
>>     
>
> 2.6.25 is'nt that old quite yet!  OK, I get the idea, anyway.
>
>   
>> .. It would be  
>> cumbersome for me to test RHCS with newer kernels. Linux is really a  
>> moving target :( ....
>>
>> Anyway, will think of something else to test this out..
>>     
>
> OK, thanks.  I did some very basic tests, and I'm not terribly worried
> about it; at worst, it's unlikely to break anything that's already
> working.  But let me know what you find out.
>
> I've sent off my merge request for 2.6.26, but I may try to bundle this
> up with a few smaller patches I think I've missed and submit another
> request before the weekend.
>   

Please do .. this has been going on for more than two years .. it would 
be ridiculous to put it off any longer. I'll see what I can do here to 
help out.

-- Wendy

