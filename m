Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:9698 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755280Ab3AWPeo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Jan 2013 10:34:44 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Alex Bligh <alex@alex.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "ian.campbell@citrix.com" <ian.campbell@citrix.com>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Date: Wed, 23 Jan 2013 15:34:42 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA91832D572@sacexcmbx05-prd.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>
			 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>
			 <E268D60FA8BCE2E18CCE24D7@Ximines.local>
		 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>
		 <734E2E0455BD4515C657BA69@Ximines.local>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>
	 <DABFD69DFA23FF330123B298@nimrod.local>
In-Reply-To: <DABFD69DFA23FF330123B298@nimrod.local>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-01-23 at 15:22 +0000, Alex Bligh wrote:
> Trond,
> 
> --On 21 January 2013 17:20:36 +0000 "Myklebust, Trond" 
> <Trond.Myklebust@netapp.com> wrote:
> 
> >> So, just to be clear, if a process is using NFS and AIO with O_DSYNC
> >> (but not O_DIRECT) - which is I think what QEMU is meant to be doing -
> >> then it should *never* be zero copy (even if writes happen to be
> >> appropriately aligned). Is that correct? If so, I can strace the
> >> process and see exactly what flags it is using.
> >>
> >
> > That is correct. If you want zero-copy, then O_DIRECT is your thing
> > (with or without aio). Otherwise, the kernel will always write to disk
> > by copying through the page cache.
> 
> Just to follow up on this, QEMU (specifically hw/xen_disk.c) was using
> O_DIRECT. If O_DIRECT is turned off, we get an additional page copy
> but the bug does not appear.
> 
> It thus appears that the root of the problem is that if an AIO NFS
> request is made with O_DIRECT, AIO can report the request is completed
> even when the segment may need to be retransmitted, and whilst the
> TCP stack correctly holds a reference to the page concerned, this
> is not currently preventing Xen unmapping it as Xen thinks the IO
> has completed.

It is not limited to aio/dio. It can happen with ordinary synchronous
O_DIRECT too.

As I said, it is a known problem and is one of the reasons why we want
to set retransmission timeouts to a high value. The real fix would be to
implement something along the lines of Ian's patchset.

> I believe this problem may apply to iSCSI and for that matter (e.g.)
> DRDB too.

I've no idea if they do zero copy to the socket in these situations. If
they do, then they probably have similar issues. The problem can be
mitigated by breaking the connection on retransmission; we can't do that
in NFS < NFSv4.1, since the duplicate replay cache is typically indexed
to the port number (and port number reuse is difficult with TCP due to
the existence of the TIME_WAIT state).

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
