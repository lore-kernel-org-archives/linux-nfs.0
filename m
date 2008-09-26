From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 15:54:53 -0400
Message-ID: <87089E47-10AE-4D41-B5BE-CCEE034C526B@oracle.com>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net> <20080925213831.GF14349@fieldses.org> <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com> <20080926184554.GA1492@fieldses.org> <1222454975.10150.8.camel@localhost> <EF58CFE4-3F4B-4985-9DEA-E61CC0DFC8EA@oracle.com> <1222456290.10150.10.camel@localhost> <20080926194421.GD1492@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39744 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751604AbYIZTzN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 15:55:13 -0400
In-Reply-To: <20080926194421.GD1492@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at Sep 26, 2008, 3:44 PM, J. Bruce Fields wrote:
> On Fri, Sep 26, 2008 at 03:11:30PM -0400, Trond Myklebust wrote:
>> On Fri, 2008-09-26 at 15:04 -0400, Chuck Lever wrote:
>>>
>>> So in light of Linus' stated position, it would be helpful for me  
>>> (and
>>> maybe others on the list) to have a good feel for when you guys are
>>> planning to push your merge-window changes to Linus before each  
>>> window
>>> opens.
>>>
>>> At the very least, since many of us do not follow LKML, would  
>>> someone
>>> commit to reflecting the LKML merge announcements to linux-nfs?   
>>> Or is
>>> there a kernel announcements list we can follow (or that we can
>>> subscribe linux-nfs to)?
>>
>> There are no announcements. The merge window starts as soon as  
>> 2.6.27 is
>> released, and lasts for 2 weeks. There has been some talk about
>> shortening it to 1 week, but that hasn't been fully decided yet.
>>
>> IOW: Assume as soon as you see the 2.6.27 announcement, that we're
>> preparing the merge.
>
> Yeah.  Unfortunately I don't know of a simple way to get just the
> release announcements.  I guess lwn.net's rss feed would get them  
> with a
> little less noise than lkml.
>
> We should probably restart sending those "what's in my tree for 2.6.x"
> messages with the tentative shortlog for the pull.  I think I did it a
> couple times and then got lazy....

The whole system makes it absolutely impossible to plan features and  
bug fixes.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
