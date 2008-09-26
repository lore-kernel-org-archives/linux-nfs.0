From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NLM: Revert parts of commit 24e36663
Date: Fri, 26 Sep 2008 15:04:13 -0400
Message-ID: <EF58CFE4-3F4B-4985-9DEA-E61CC0DFC8EA@oracle.com>
References: <20080924184732.4078.83334.stgit@tarkus.1015granger.net> <20080925213831.GF14349@fieldses.org> <AED0D581-07B0-4EC6-90AB-2F61B6F3C76B@oracle.com> <20080926184554.GA1492@fieldses.org> <1222454975.10150.8.camel@localhost>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:22069 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784AbYIZTE2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 15:04:28 -0400
In-Reply-To: <1222454975.10150.8.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep 26, 2008, at Sep 26, 2008, 2:49 PM, Trond Myklebust wrote:
> On Fri, 2008-09-26 at 14:45 -0400, J. Bruce Fields wrote:
>>> If so, we could post it after
>>> the merge window closes.  It would give a little more time to do  
>>> some
>>> testing.
>>
>> That sound suspiciously like "since this is a high priority, it  
>> will be
>> accepted later, so we can make it a lower priority."  Help!

No, more like "I have way too much to do in the next week because I'm  
out two days, and am required to finish an ethics course before the  
30th."  I don't think there's much to do to get this in shape, I just  
don't want to make promises I can't keep.

>> But anyway, yes, we might have more time.
>
> At the Kernel Summit Linus said he wants this kind of fix to go into  
> the
> merge window rather than in the -rc series if possible. His position  
> was
> that he'd rather revert a bad fix instead of delaying the testing in  
> the
> mainline kernel...

So in light of Linus' stated position, it would be helpful for me (and  
maybe others on the list) to have a good feel for when you guys are  
planning to push your merge-window changes to Linus before each window  
opens.

At the very least, since many of us do not follow LKML, would someone  
commit to reflecting the LKML merge announcements to linux-nfs?  Or is  
there a kernel announcements list we can follow (or that we can  
subscribe linux-nfs to)?

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
