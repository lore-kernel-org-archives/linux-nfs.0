Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:20635 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752922Ab3AURUj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 12:20:39 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Alex Bligh <alex@alex.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "ian.campbell@citrix.com" <ian.campbell@citrix.com>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Date: Mon, 21 Jan 2013 17:20:36 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA915C1781E@SACEXCMBX04-PRD.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>
		 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>
		 <E268D60FA8BCE2E18CCE24D7@Ximines.local>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>
	 <734E2E0455BD4515C657BA69@Ximines.local>
In-Reply-To: <734E2E0455BD4515C657BA69@Ximines.local>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-01-21 at 17:12 +0000, Alex Bligh wrote:
> Trond,
> 
> --On 21 January 2013 15:50:48 +0000 "Myklebust, Trond" 
> <Trond.Myklebust@netapp.com> wrote:
> 
> >> I don't think QEMU is actually using O_DIRECT unless I set cache=none
> >> on the drive. That causes a different interesting failure which isn't
> >> my focus just now!
> >
> > Then your reference to Ian's bug is a red herring.
> >
> > If the application is using buffered writes, then the data is
> > immediately copied from userspace to the page cache. Once the copy to
> > the page cache is done, userspace can do whatever it wants with the
> > original buffer, because only the page cache pages are used in the RPC
> > calls.
> >
> > aio doesn't change any of this...
> 
> So, just to be clear, if a process is using NFS and AIO with O_DSYNC
> (but not O_DIRECT) - which is I think what QEMU is meant to be doing -
> then it should *never* be zero copy (even if writes happen to be
> appropriately aligned). Is that correct? If so, I can strace the
> process and see exactly what flags it is using.
> 

That is correct. If you want zero-copy, then O_DIRECT is your thing
(with or without aio). Otherwise, the kernel will always write to disk
by copying through the page cache.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
