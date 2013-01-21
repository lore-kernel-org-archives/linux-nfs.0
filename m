Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.avalus.com ([89.16.176.221]:35920 "EHLO mail.avalus.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755947Ab3AUPKS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 Jan 2013 10:10:18 -0500
Date: Mon, 21 Jan 2013 15:10:03 +0000
From: Alex Bligh <alex@alex.org.uk>
Reply-To: Alex Bligh <alex@alex.org.uk>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
cc: linux-nfs@vger.kernel.org, Ian Campbell <Ian.Campbell@citrix.com>,
        Alex Bligh <alex@alex.org.uk>
Subject: Re: Fatal crash with NFS, AIO & tcp retransmit
Message-ID: <4B8CA29C9B365854E56ACBE6@Ximines.local>
In-Reply-To: <E268D60FA8BCE2E18CCE24D7@Ximines.local>
References: <93D3AE9B4990994B2BCA75A9@Ximines.local>
 <4FA345DA4F4AE44899BD2B03EEEC2FA915C163B9@SACEXCMBX04-PRD.hq.netapp.com>
 <E268D60FA8BCE2E18CCE24D7@Ximines.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And again with Ian's correct email address. Sorry all.

--On 21 January 2013 15:01:54 +0000 Alex Bligh <alex@alex.org.uk> wrote:

> Trond,
>
> --On 21 January 2013 14:38:20 +0000 "Myklebust, Trond"
> <Trond.Myklebust@netapp.com> wrote:
>
>> The Oops would be due to a bug in the socket layer: the socket is
>> supposed to take a reference count on the page in order to ensure that
>> it can copy the contents.
>
> Looking at the original linux-nfs link, you said here:
> http://marc.info/?l=linux-nfs&m=122424789508577&w=2
>
> Trond:> I don't see how this could be an RPC bug. The networking
> Trond:> layer is supposed to either copy the data sent to the socket,
> Trond:> or take a reference to any pages that are pushed via
> Trond:> the ->sendpage() abi.
>
> which sounds suspiciously like the same thing.
>
> The conversation then went:
> http://marc.info/?l=linux-nfs&m=122424858109731&w=2
> Ian:> The pages are still referenced by the networking layer. The problem
> is
> Ian:> that the userspace app has been told that the write has completed so
> Ian:> it is free to write new data to those pages.
>
> To which you replied:
> http://marc.info/?l=linux-nfs&m=122424984612130&w=2
> Trond:> OK, I see your point.
>
> Following the thread, it then seems that Ian's test case did fail on
> NFS4 on 2.6.18, but not on 2.6.27.
>
> Note that Ian was seeing something slightly different from me. I think
> what he was seeing was alterations to the page after AIO completes
> being retransmitted when the page prior to the alteration should
> be transmitted. That could presumably be fixed by some COW device.
>
> What I'm seeing is more subtle. Xen thinks (because QEMU tells it,
> because AIO tells it) that the memory is done with entirely, and
> simply unmaps it. I don't think that's Qemu's fault.
>
> If it is a referencing issue, then it seems to me the problem is
> that Xen is releasing the grant structure (I don't quite understand
> how this bit works) and unmapping memory when the networking stack
> still holds a reference to the page concerned. However, even if it
> did not do that, wouldn't a retransmit after the write had completed
> risk writing the wrong data? I suppose it could mark the page
> COW before it released the grant or something.
>
>> As for the O_DIRECT bug, the problem there is that we have no way of
>> knowing when the socket is done writing the page. Just because we got an
>> answer from the server doesn't mean that the socket is done
>> retransmitting the data. It is quite possible that the server is just
>> replying to the first transmission.
>
> I don't think QEMU is actually using O_DIRECT unless I set cache=none
> on the drive. That causes a different interesting failure which isn't
> my focus just now!
>
>> I thought that Ian was working on a fix for this issue. At one point, he
>> had a bunch of patches to allow sendpage() to call you back when the
>> transmission was done. What happened to those patches?
>
> No idea (I don't work with Ian but have taken the liberty of copy him).
>
> However, what's happened in the intervening years is that Xen has changed
> its device model and it's now QEMU doing the writing (the qcow2 driver
> specifically). I'm not sure it's even using sendpage.
>
> --
> Alex Bligh
>
>



-- 
Alex Bligh
