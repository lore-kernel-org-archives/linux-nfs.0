Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.eu.citrix.com ([46.33.159.39]:48161 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499Ab3AUPy5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 10:54:57 -0500
Message-ID: <1358783694.3279.237.camel@zakaz.uk.xensource.com>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
From: Ian Campbell <Ian.Campbell@citrix.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Alex Bligh <alex@alex.org.uk>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Mon, 21 Jan 2013 15:54:54 +0000
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>
	 <E268D60FA8BCE2E18CCE24D7@Ximines.local>
	 <4FA345DA4F4AE44899BD2B03EEEC2FA915C17543@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-01-21 at 15:50 +0000, Myklebust, Trond wrote:
> On Mon, 2013-01-21 at 15:01 +0000, Alex Bligh wrote:
> > Trond,
> > 
> > --On 21 January 2013 14:38:20 +0000 "Myklebust, Trond" 
> > <Trond.Myklebust@netapp.com> wrote:
> > 
> > > The Oops would be due to a bug in the socket layer: the socket is
> > > supposed to take a reference count on the page in order to ensure that
> > > it can copy the contents.
> > 
> > Looking at the original linux-nfs link, you said here:
> > http://marc.info/?l=linux-nfs&m=122424789508577&w=2
> > 
> > Trond:> I don't see how this could be an RPC bug. The networking
> > Trond:> layer is supposed to either copy the data sent to the socket,
> > Trond:> or take a reference to any pages that are pushed via
> > Trond:> the ->sendpage() abi.
> > 
> > which sounds suspiciously like the same thing.
> > 
> > The conversation then went:
> > http://marc.info/?l=linux-nfs&m=122424858109731&w=2
> > Ian:> The pages are still referenced by the networking layer. The problem is
> > Ian:> that the userspace app has been told that the write has completed so
> > Ian:> it is free to write new data to those pages.
> > 
> > To which you replied:
> > http://marc.info/?l=linux-nfs&m=122424984612130&w=2
> > Trond:> OK, I see your point.
> 
> The original thread did not AFAICR involve an Oops. If you are seeing an
> Oops, then that is something new and would be a socket level bug.

The oops would be Xen specific, in the case where on native you would
touch the buffer after a write completed and potentially resend changed
data on Xen you would see an unmapped addresss.

The underlying issue is the same, just the consequence on Xen is a bit
more obvious.

[...]
> > I don't think QEMU is actually using O_DIRECT unless I set cache=none
> > on the drive. That causes a different interesting failure which isn't
> > my focus just now!
> 
> Then your reference to Ian's bug is a red herring.

Agreed, if there is no zero copy going on then this is a separate issue.

Ian.

