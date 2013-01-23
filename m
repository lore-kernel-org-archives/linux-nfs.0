Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:53800 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755735Ab3AWRmO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 12:42:14 -0500
Date: Wed, 23 Jan 2013 17:42:01 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, ian.campbell@citrix.com,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <F1BFF24EE9BEF6E4C8C66BF8@nimrod.local>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA918331EF5@sacexcmbx05-prd.hq.netapp.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

--On 23 January 2013 17:37:08 +0000 "Myklebust, Trond" 
<Trond.Myklebust@netapp.com> wrote:

>> If you break the connection, and the written data is now not available
>> to dom0 (as it's been mapped out), how would it ever get resent? IE
>> it's not going to be available to the RPC layer either.
>
> There are typically more than 1 outstanding RPC call at any one time.
> Breaking the connection would affect those other RPC calls.

I understand that. I meant 'how does the write which failed ever
get retransmitted now the data to be written has been lost?'

-- 
Alex Bligh
