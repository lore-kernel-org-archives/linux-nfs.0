From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: unlock lockd locks held for a certain filesystem
Date: Wed, 23 Apr 2008 17:39:19 -0400
Message-ID: <20080423213918.GH8302@fieldses.org>
References: <4808A9DE.9040304@gmail.com> <20080418181918.GB24552@fieldses.org> <20080422231520.GI21770@fieldses.org> <20080422231729.GJ21770@fieldses.org> <20080422231855.GK21770@fieldses.org> <20080423074422.GA23518@lst.de> <20080423171240.GG31576@fieldses.org> <480F9E6F.4070204@gmail.com> <20080423210227.GF8302@fieldses.org> <480FA769.40900@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, nfs@lists.sourceforge.net,
	linux-nfs@vger.kernel.org, Lon Hohberger <lhh@redhat.com>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:51245 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753119AbYDWVjX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Apr 2008 17:39:23 -0400
In-Reply-To: <480FA769.40900@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 23, 2008 at 05:17:29PM -0400, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> On Wed, Apr 23, 2008 at 04:39:11PM -0400, Wendy Cheng wrote:
>>   
>>> #if defined(BRUCE_CHECK_THIS_OUT)
>>> error = nlmsvc_failover_path(nd.path.mnt->mnt_sb);
>>> #else
>>> error = nlmsvc_failover_path(nd.mnt->mnt_sb);
>>> #endif
>>>     
>>
>> The vfsmount and dentry got moved into the path argument sometime in the
>> last kernel version or so.  Is there a macro defining the latter as a
>> shortcut for the former?  I didn't see one.
>>
>>
>>   
> Sorry, just realized my kernel is too old (2.6.25)

2.6.25 is'nt that old quite yet!  OK, I get the idea, anyway.

> .. It would be  
> cumbersome for me to test RHCS with newer kernels. Linux is really a  
> moving target :( ....
>
> Anyway, will think of something else to test this out..

OK, thanks.  I did some very basic tests, and I'm not terribly worried
about it; at worst, it's unlikely to break anything that's already
working.  But let me know what you find out.

I've sent off my merge request for 2.6.26, but I may try to bundle this
up with a few smaller patches I think I've missed and submit another
request before the weekend.

--b.
