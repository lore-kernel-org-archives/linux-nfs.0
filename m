Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fw1.franz.com ([67.207.112.66]:46106 "EHLO mas.franz.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753336Ab3EFSGH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 May 2013 14:06:07 -0400
From: Ahmon Dancy <dancy@franz.com>
To: Wendy Cheng <s.wendy.cheng@gmail.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: Unexpected NFS client cache drops
In-reply-to: <CABgxfbEuf-YfJT+7PTnXJvtetjaUCVez2EAoK1Q6azYN4Oib=g@mail.gmail.com>
References: <16805.1367508760@mas.franz.com> <CABgxfbEuf-YfJT+7PTnXJvtetjaUCVez2EAoK1Q6azYN4Oib=g@mail.gmail.com>
Date: Mon, 06 May 2013 11:05:45 -0700
Message-ID: <11469.1367863545@mas.franz.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wendy Cheng <s.wendy.cheng@gmail.com> wrote:

>> On Thu, May 2, 2013 at 8:32 AM, Ahmon Dancy <dancy@franz.com> wrote:
>> > Hello Linux NFS folks.  I need help figuring out why the kernel is
>> > sometimes discarding large portions of the page cache for a file that
>> > I'm manipulating via NFS.
>> 
>> It is quite normal for kernel to flush out page cache and there are
>> tunables to control the intervals and/or percentage. For example, a
>> quick googling shows results such as:
>> http://www.westnet.com/~gsmith/content/linux-pdflush.htm  .. Did you
>> try that out yet ?

The document you refer to is about how the kernel performs writeback.
My complaint is about the kernel unnecessarily invalidating the cache.

>> 
>> Different filesystems have different policies for flushing as well -
>> this applies to NFS client and local filesystems. NFS client kmod
>> might clean its house more frequently due to:
>> 
>> 1. It has more memory pressure (vs. local filesystem that does not
>> require socket buffers), particularly you run this on top of IB
>> interconnect that uses DMA extensively. Did you use IPOIB datagram or
>> IPOIB cm ?

I should note that I also witnessed the bad behavior on a system that
did not use Infiniband so, while I mentioned it in my original problem
report, I don't think Infiniband is really implicated in this issue.

>> 2. NFS default with sync export - so the client side pages may have
>> zero reference count (read as "un-used") after the contents reach the
>> server. At that point, kernel is free to grab them

So that's where my question comes in. Why is it doing so when there is
no memory pressure (tens of gigabytes free on both NUMA nodes while
I'm testing).

>> > Attached is the source for a test program which models the behavior of
>> > a larger program.  The program works as follows:
>> >
>> 
>> A test program is always a great way to kickoff the discussion. If you
>> don't get further comment here, you might want to open a Fedora
>> bugzilla to see whether anyone has cycles to run it and analyse the
>> result. I suspect there are more tunable can be done on the NUMA
>> side.

Will do.  I wasn't sure which was the best course of action (going
through RedHat or going directly to the NFS mailing list).

>> I assume the hardware used by the xfs runs were identical to the NFS
>> client machine.

That's correct. 



Additional note: I did another test from the same client against an
NFS server exporting an ext3 filesystem and the problem happens much
sooner.  I'm guessing filesystem timestamp resolution is coming into
play here.
