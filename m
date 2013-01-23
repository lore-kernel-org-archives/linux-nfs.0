Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:42037 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756551Ab3AWReH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 12:34:07 -0500
Date: Wed, 23 Jan 2013 17:33:53 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, ian.campbell@citrix.com,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <5B18F9B0446E7F3CAA3BD81D@nimrod.local>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA91832D572@sacexcmbx05-prd.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>			
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>			
 <E268D60FA8BCE2E18CCE24D7@Ximines.local>		
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>		
 <734E2E0455BD4515C657BA69@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>	
 <DABFD69DFA23FF330123B298@nimrod.local>
 <4FA345DA4F4AE44899BD2B03EEEC2FA91832D572@sacexcmbx05-prd.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



--On 23 January 2013 15:34:42 +0000 "Myklebust, Trond" 
<Trond.Myklebust@netapp.com> wrote:

> I've no idea if they do zero copy to the socket in these situations. If
> they do, then they probably have similar issues. The problem can be
> mitigated by breaking the connection on retransmission; we can't do that
> in NFS < NFSv4.1, since the duplicate replay cache is typically indexed
> to the port number (and port number reuse is difficult with TCP due to
> the existence of the TIME_WAIT state).

If you break the connection, and the written data is now not available
to dom0 (as it's been mapped out), how would it ever get resent? IE
it's not going to be available to the RPC layer either.

-- 
Alex Bligh
