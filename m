From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/3] client-side lockd doesn't start UDP listener
Date: Tue, 14 Oct 2008 11:52:52 -0400
Message-ID: <5ACEC030-6463-445B-9B1B-9220EB3566C5@oracle.com>
References: <20081003211305.9870.6835.stgit@ingres.1015granger.net> <20081004213625.GA3709@fieldses.org> <18674.34066.316972.695627@notabene.brown> <CCAC2CA2-FEAE-4383-9F7D-F63BBF0E701E@oracle.com> <20081013174613.GH28864@fieldses.org> <668D398B-7814-4831-ABC2-8F8CF1FBE4D0@oracle.com> <18676.27741.921124.742371@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:25052 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbYJNP42 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Oct 2008 11:56:28 -0400
In-Reply-To: <18676.27741.921124.742371-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 14, 2008, at Oct 14, 2008, 5:54 AM, Neil Brown wrote:
> On Monday October 13, chuck.lever@oracle.com wrote:
>>
>> NFSD start-up code makes two separate and unconditional calls to
>> lockd_up(): one for UDP and one for TCP.  So whether or not NFSD
>> actually honors the "-T" and "-U" flags, lockd certainly does not
>> honor them in current (unpatched) code.
>
> Not exactly correct.  The calls are not unconditional.
> I assume we are looking at nfsd_init_socks in nfssvc.c
> Note the condition at the top:
> 	if (!list_empty(&nfsd_serv->sv_permsocks))
> 		return 0;
>
> If a UDP port has previously been created by a write to "portlist",
> then when the first thread is stared, no new sockets will be created,
> and nfsd (and lockd) will just listen on UDP.
>
> So your patches do make a real functional change which is more than
> just "always listen on UDP".

OK, I'm already collecting a set of additional fixes and cleanups in  
this area for 2.6.29.  We can add this to the list.

Why are there two separate and undocumented kernel interfaces for  
starting NFSD?

> I agree that the man page should reflect reality.

Several people have said that, but no-one has suggested what specific  
parts of the man page are problematic.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
