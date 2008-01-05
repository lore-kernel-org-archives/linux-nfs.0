From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [PATCH] Fix NLM reference count panic
Date: Sat, 05 Jan 2008 12:46:21 -0500
Message-ID: <477FC26D.5010505@redhat.com>
References: <477EB7D1.9030303@redhat.com> <20080104232422.GF14827@fieldses.org> <477F0F8B.9020706@redhat.com> <20080105060509.GA29020@fieldses.org>
Reply-To: wcheng@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: NFS list <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57190 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106AbYAER3V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 5 Jan 2008 12:29:21 -0500
In-Reply-To: <20080105060509.GA29020@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:

>On Sat, Jan 05, 2008 at 12:03:07AM -0500, Wendy Cheng wrote:
>  
>
>>J. Bruce Fields wrote:
>>
>>    
>>
>>>On Fri, Jan 04, 2008 at 05:48:49PM -0500, Wendy Cheng wrote:
>>>This just replaces the file->f_locks check by a search of the inode's
>>>lock list.
>>>
>>>What confuses me here is that the nlm_inspect_file() call just above
>>>already did that search, and set file->f_locks accordingly.  The only
>>>difference is that now we've acquired the nlm_file_mutex.  I don't
>>>understand yet how that makes a difference.
>>>
>>> 
>>>      
>>>
>>You're right. I got the patch sequence wrong. It will cause panic only when 
>>we selectively unlock nlm locks under my "unlock" patch as the following. 
>>See how it returns without doing nlm_traverse_locks() below ... Let's 
>>combine this patch into the big unlock patch so we won't have any 
>>confusion. The unlock patch will submitted on Monday after this weekend's 
>>sanity check test run. In short, I withdraw this patch... Wendy
>>    
>>
>
>OK.  I'll admit to still being a little confused--but with luck it'll
>all make sense when I see the whole thing.  Have a good weekend!
>
>  
>
Actually the *existing* logic (implying without my changes) is awkward. 
It uses file->f_locks to carry the result of unlock operation. Leave the 
non-zero f_locks value hanging there if unlock fails, It only resets it 
back to zero when next time nlm_inspect_file is called. Code like this 
is a good place to generate subtle race conditions that could result 
with file close failure. Just a complaint - I don't have a solid proof 
that it has caused troubles though.

Anyway, will combine this small patch into the big unlock patch. You 
have a good weekend too !

-- Wendy
