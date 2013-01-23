Return-Path: linux-nfs-owner@vger.kernel.org
Received: from p02c12o145.mxlogic.net ([208.65.145.78]:49559 "EHLO
	p02c12o145.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339Ab3AWR55 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 12:57:57 -0500
From: Peter Staubach <pstaubach@exagrid.com>
To: Alex Bligh <alex@alex.org.uk>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "ian.campbell@citrix.com" <ian.campbell@citrix.com>
Date: Wed, 23 Jan 2013 12:48:50 -0500
Subject: RE: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <FA8A9A935BFD3A4D8F0CDA1C4F611BCC0C5DC79D53@IT-1874.Isys.com>
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
In-Reply-To: <F1BFF24EE9BEF6E4C8C66BF8@nimrod.local>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi.

The theory is that the modified pages which need to get written to the server can't be released until they have been successfully written and committed to stable storage on the server.

They can't disappear until they have been successfully transmitted and a response received.  The problem here is that there were two requests sent or being sent and the page(s) can't be released until everyone, including TCP and such, are done with them.

		ps


-----Original Message-----
From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Alex Bligh
Sent: Wednesday, January 23, 2013 12:42 PM
To: Myklebust, Trond
Cc: linux-nfs@vger.kernel.org; ian.campbell@citrix.com; Alex Bligh
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit

Trond,

--On 23 January 2013 17:37:08 +0000 "Myklebust, Trond" 
<Trond.Myklebust@netapp.com> wrote:

>> If you break the connection, and the written data is now not 
>> available to dom0 (as it's been mapped out), how would it ever get 
>> resent? IE it's not going to be available to the RPC layer either.
>
> There are typically more than 1 outstanding RPC call at any one time.
> Breaking the connection would affect those other RPC calls.

I understand that. I meant 'how does the write which failed ever get retransmitted now the data to be written has been lost?'

--
Alex Bligh
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html
