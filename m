Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:58358 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751687Ab3AWTiM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 14:38:12 -0500
Date: Wed, 23 Jan 2013 19:37:55 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Peter Staubach <pstaubach@exagrid.com>
cc: linux-nfs@vger.kernel.org, ian.campbell@citrix.com,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <7CD6CC530A524B9745F846FB@nimrod.local>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA918332049@sacexcmbx05-prd.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>	
 <E268D60FA8BCE2E18CCE24D7@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>	
 <734E2E0455BD4515C657BA69@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>	
 <DABFD69DFA23FF330123B298@nimrod.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA91832D572@sacexcmbx05-prd.hq.netapp.com>	
 <5B18F9B0446E7F3CAA3BD81D@nimrod.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA918331EF5@sacexcmbx05-prd.hq.netapp.com>	
 <F1BFF24EE9BEF6E4C8C66BF8@nimrod.local>	
 <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C5DC79D53@IT-1874.Isys.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA918332049@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



--On 23 January 2013 18:13:34 +0000 "Myklebust, Trond" 
<Trond.Myklebust@netapp.com> wrote:

>> They can't disappear until they have been successfully transmitted and a
>> response received.  The problem here is that there were two requests
>> sent or being sent and the page(s) can't be released until everyone,
>> including TCP and such, are done with them.
>>
>> 		ps
>
> Right. The O_DIRECT write() system call will not return until it gets a
> reply. Similarly, we don't mark an aio/dio request as complete until it
> too gets a reply. So the data for those requests that need
> retransmission is still available to be resent through the socket.

I apologise for my stupidity here as I think I must be missing something.

I thought we'd established that Xen's grant system doesn't release the page
until QEMU says the block I/O is complete. QEMU only states that the block
I/O is complete when AIO says it is. What's happening (as far as I can tell
from the oops) is that the grant system is releasing the page AFTER the aio
request is complete (and dio may the same), but at that stage the page is
still referenced by the tcp stack. That contradicts what you say about not
marking the aio/dio request as complete until it gets a reply, unless it's
the case that you can get a reply to a request when there is still data
that the TCP stack can ask to retransmit (I suppose that's conceivable
if the reply gets sent before the ACK of the data received).

My understanding (which may well be completely wrong) is that the problem
was that xen was unmapping the page even though it still had kernel
references to it. This is why the problem does not happen in kvm (which
does not as I understand it do a similar map/unmap operation). From Ian C I
understand that just looking at the number of kernel references is not
sufficient.

-- 
Alex Bligh
