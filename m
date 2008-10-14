From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Tue, 14 Oct 2008 14:14:17 -0400
Message-ID: <CBD20FFC-5D0D-450A-B882-6A70FB326130@oracle.com>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net> <20081004213625.GA3709@fieldses.org> <18674.34066.316972.695627@notabene.brown> <CCAC2CA2-FEAE-4383-9F7D-F63BBF0E701E@oracle.com> <20081013174613.GH28864@fieldses.org> <668D398B-7814-4831-ABC2-8F8CF1FBE4D0@oracle.com> <18676.27741.921124.742371@notabene.brown> <5ACEC030-6463-445B-9B1B-9220EB3566C5@oracle.com> <20081014174339.GD17899@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:48912 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751272AbYJNSOk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2008 14:14:40 -0400
In-Reply-To: <20081014174339.GD17899@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 14, 2008, at Oct 14, 2008, 1:43 PM, J. Bruce Fields wrote:
> On Tue, Oct 14, 2008 at 11:52:52AM -0400, Chuck Lever wrote:
>> On Oct 14, 2008, at Oct 14, 2008, 5:54 AM, Neil Brown wrote:
>>> I agree that the man page should reflect reality.
>>
>> Several people have said that, but no-one has suggested what specific
>> parts of the man page are problematic.
>
> Look at, e.g., the text for "-T":
> 	Disable rpc.nfsd from accepting TCP connections from clients.
>
> It should probably say lockd is unaffected.  (If that's what we want.)

That's the problem.  I'm not sure how this should behave.  I don't  
know what the implications are of always having both lockd listeners  
on the server.

It seems to me the previous behavior must have been broken -- if -U is  
specified, rpc.nfsd prevents the creation of both lockd and nfsd  
listeners on UDP, thus we have the same lock recovery problem we have  
on the client.

So we must always have a lockd UDP listener on the server, at least.

I would like to understand why we have -T and -U, and whether users of  
these options might want lockd to reflect the setting of this option.   
Is it acceptable (does it make sense) to have both UDP and TCP  
listeners for lockd, while having just one listener for NFSD?

And I don't understand what is being accomplished with the check that  
prevents nfsd_init_socks() from starting additional listeners.  Neil  
did this recently enough that I'm hoping he remembers what the  
rationale was and then we can add a comment or two in fs/nfsd/nfsctl.c  
to help inform future generations.

> Also the wording is a little imprecise, since rpc.nfsd itself doesn't
> accept network connections.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
