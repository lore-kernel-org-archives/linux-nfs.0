Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:45498 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753830Ab3AXMAa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Jan 2013 07:00:30 -0500
Date: Thu, 24 Jan 2013 12:00:14 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: Ian Campbell <Ian.Campbell@citrix.com>
cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Peter Staubach <pstaubach@exagrid.com>, linux-nfs@vger.kernel.org,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <F48D1289B377F7EC54BA1FE0@nimrod.local>
In-Reply-To: <1359024131.17440.123.camel@zakaz.uk.xensource.com>
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
 <7CD6CC530A524B9745F846FB@nimrod.local>
 <1359024131.17440.123.camel@zakaz.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ian,

--On 24 January 2013 10:42:11 +0000 Ian Campbell <Ian.Campbell@citrix.com> 
wrote:

> This is exactly what can happen:
>
>      1. send request (A)
>      2. timeout waiting for ACK to (A)
>      3. queue TCP retransmit of (A) as (B)
>      4. receive ACK to original (A), sent at #1, and rpc reply to that
>         request.
>      5. return success to userspace
>      6. userspace reuses (or unmaps under Xen) the buffer
>      7. (B), queued at #3, reaches the head of the queue
>      8. Try to transmit (B), bug has now happened.
>
> You can also s/TCP/RPC/ and construct a similar issue at the next layer
> of the stack, which only happens on NFSv3 AIUI.

Got it - finally! Thanks for your patience in explaining.

I am guessing a simpler fix for the tcp retransmit problem would be
to copy (or optionally copy) the page(s) for B at step 3. Given tcp
retransmit is infrequent and performance is not going to be good
with tcp retransmissions going on anyway, that might be acceptable.
However in practice *anything* that causes a multiple references
to a page in the networking stack is going to have this problem,
and multiple skbuff's can refer to the same page, which is I presume
why you were fixing this by skbuff reference counting, presumably
so you know you can do (5) only when the skbuff is entirely unreferenced
(i.e. after (8)).

>> My understanding (which may well be completely wrong) is that the problem
>> was that xen was unmapping the page even though it still had kernel
>> references to it. This is why the problem does not happen in kvm (which
>> does not as I understand it do a similar map/unmap operation). From Ian
>> C I understand that just looking at the number of kernel references is
>> not sufficient.
>
> Under any userspace process (which includes KVM) you get retransmission
> of data which may have changed, because userspace believes the kernel
> when it has said it is done with it, and has reused the buffer. All that
> is different under Xen is that "changed" can mean "unmapped" which makes
> the symptom much worse.

Indeed. And the fact that kvm by default does not use O_DIRECT whereas
xen_disk.c does, so kvm will hide the problem as a copy is performed in (1).

-- 
Alex Bligh
