From: Oleg Drokin <Oleg.Drokin-UdXhSnd/wVw@public.gmane.org>
Subject: Re: [PATCH 039/100] lockd: fix a leak in nlmsvc_testlock asynchronous
 request handling
Date: Mon, 28 Jan 2008 15:28:42 -0500
Message-ID: <DFDA54A4-803B-400F-98BD-59E93FC2214C@Sun.COM>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; delsp=yes; format=flowed; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from brmea-mail-1.Sun.COM ([192.18.98.31]:50295 "EHLO
	brmea-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752412AbYA1U6h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Jan 2008 15:58:37 -0500
Received: from fe-amer-09.sun.com ([192.18.109.79])
	by brmea-mail-1.sun.com (8.13.6+Sun/8.12.9) with ESMTP id m0SKSpKM014638
	for <linux-nfs@vger.kernel.org>; Mon, 28 Jan 2008 20:28:51 GMT
Received: from conversion-daemon.mail-amer.sun.com by mail-amer.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JVD00B01EAGT700-suYR2Hc8r9/lQFUxb2hVpgC/G2K4zDHf@public.gmane.org>
 (original mail from Oleg.Drokin-UdXhSnd/wVw@public.gmane.org) for linux-nfs@vger.kernel.org; Mon,
 28 Jan 2008 13:28:51 -0700 (MST)
In-reply-to: <416FFE80-EC89-43DD-A385-5BBE873FF469@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

On Jan 28, 2008, at 3:17 PM, Chuck Lever wrote:
>> @@ -501,25 +501,29 @@ nlmsvc_testlock(struct svc_rqst *rqstp,  
>> struct nlm_file *file,
>> 			block, block->b_flags, block->b_fl);
>> 		if (block->b_flags & B_TIMED_OUT) {
>> 			nlmsvc_unlink_block(block);
>> -			return nlm_lck_denied;
>> +			ret = nlm_lck_denied;
>> +			goto out;
> Aren't we also leaking the memory pointed to by block->b_fl that  
> nlmsvc_testlock just allocated?

When last reference on a block goes away, nlmsvc_free_block is called  
that frees block->b_fl, so we are good here, I think.

> nlmsvc_unlink_block() already invokes nlmsvc_release_block() in some  
> cases.  So now sometimes we have a double release.

It in fact always calls release_block, but this is not a free  
function, this is sort of refput function instead.
We got one reference on a block (from lookup_block/create_block) that  
we release after out label, and one that i consumed
by a list membership. When we unlink a block from a list, we drop that  
reference too.

Bye,
     Oleg
