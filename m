Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.netapp.com ([216.240.18.38]:51474 "EHLO mx1.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755480Ab3AWRhL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 12:37:11 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Alex Bligh <alex@alex.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "ian.campbell@citrix.com" <ian.campbell@citrix.com>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Date: Wed, 23 Jan 2013 17:37:08 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA918331EF5@sacexcmbx05-prd.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>
				 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>
				 <E268D60FA8BCE2E18CCE24D7@Ximines.local>
			 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>
			 <734E2E0455BD4515C657BA69@Ximines.local>
		 <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>
		 <DABFD69DFA23FF330123B298@nimrod.local>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA91832D572@sacexcmbx05-prd.hq.netapp.com>
	 <5B18F9B0446E7F3CAA3BD81D@nimrod.local>
In-Reply-To: <5B18F9B0446E7F3CAA3BD81D@nimrod.local>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-01-23 at 17:33 +0000, Alex Bligh wrote:
> 
> --On 23 January 2013 15:34:42 +0000 "Myklebust, Trond" 
> <Trond.Myklebust@netapp.com> wrote:
> 
> > I've no idea if they do zero copy to the socket in these situations. If
> > they do, then they probably have similar issues. The problem can be
> > mitigated by breaking the connection on retransmission; we can't do that
> > in NFS < NFSv4.1, since the duplicate replay cache is typically indexed
> > to the port number (and port number reuse is difficult with TCP due to
> > the existence of the TIME_WAIT state).
> 
> If you break the connection, and the written data is now not available
> to dom0 (as it's been mapped out), how would it ever get resent? IE
> it's not going to be available to the RPC layer either.

There are typically more than 1 outstanding RPC call at any one time.
Breaking the connection would affect those other RPC calls.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
