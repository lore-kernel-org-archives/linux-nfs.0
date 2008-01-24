From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] NLM failover unlock commands
Date: Thu, 24 Jan 2008 16:40:29 -0500
Message-ID: <20080124214029.GK26164@fieldses.org>
References: <478F78E8.40601@redhat.com> <20080117163105.GG16581@fieldses.org> <478F82DA.4060709@redhat.com> <20080117164002.GH16581@fieldses.org> <478F9946.9010601@redhat.com> <20080117202342.GA6416@fieldses.org> <20080124160030.GB26164@fieldses.org> <4798EAE1.2000707@redhat.com> <20080124201910.GF26164@fieldses.org> <4798FDE9.4040406@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, Christoph Hellwig <hch@infradead.org>,
	NFS list <linux-nfs@vger.kernel.org>, cluster-devel@redhat.com
To: Wendy Cheng <wcheng@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59360 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756791AbYAXVke (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jan 2008 16:40:34 -0500
In-Reply-To: <4798FDE9.4040406@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 24, 2008 at 04:06:49PM -0500, Wendy Cheng wrote:
> J. Bruce Fields wrote:
>> On Thu, Jan 24, 2008 at 02:45:37PM -0500, Wendy Cheng wrote:
>>   
>>> J. Bruce Fields wrote:
>>>     
>>>> In practice, it seems that both the unlock_ip and unlock_pathname
>>>> methods that revoke locks are going to be called together.  The two
>>>> separate calls therefore seem a little redundant.  The reason we *need*
>>>> both is that it's possible that a misconfigured client could grab locks
>>>> for a (server ip, export) combination that it isn't supposed to.
>>>>         
>>> That is not a correct assumption. The two commands (unlock_ip and   
>>> unlock_pathname) are not necessarily called together. It is ok for 
>>> local  filesystem (ext3) but not for cluster filesystem where the 
>>> very same  filesystem (or subtree) can be exported from multiple 
>>> servers using  different subtrees.
>>>     
>>
>> Ouch.  Are people really doing that, and why?  What happens if the
>> subtrees share files (because of hard links) that are locked from both
>> nodes?
>>   
>
> It is *more* common than you would expect - say server1 exports  
> "/mnt/gfs/maildir/namea-j" and server2 exports 
> "/mnt/gfs/maildir/namek-z".

I believe it, but how hard would it be for them to just set those up as
separate partitions?

I'm really not fond of exports of subdirectories of filesystems, mainly
because I'm worried that many administrators don't understand the
security issue (which is that they probably are exposing the whole
filesystem when they export a subdirectory).

--b.
