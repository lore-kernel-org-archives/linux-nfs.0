Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:48119 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751273Ab3AUR3s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2013 12:29:48 -0500
Date: Mon, 21 Jan 2013 17:29:35 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, ian.campbell@citrix.com,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <50A25C98A7223D35C994B64D@Ximines.local>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>		
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>		
 <E268D60FA8BCE2E18CCE24D7@Ximines.local>	
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>	
 <734E2E0455BD4515C657BA69@Ximines.local>
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond,

--On 21 January 2013 17:20:36 +0000 "Myklebust, Trond" 
<Trond.Myklebust@netapp.com> wrote:

> That is correct. If you want zero-copy, then O_DIRECT is your thing
> (with or without aio). Otherwise, the kernel will always write to disk
> by copying through the page cache.

Thanks. From the crash dump it appeared to be accessing mapped memory
somehow, so I'll see whether QEMU is in fact using O_DIRECT contrary
to documentation.

-- 
Alex Bligh
