Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49625 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbbGBIZd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 04:25:33 -0400
Date: Thu, 2 Jul 2015 09:25:30 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
Message-ID: <20150702082529.GJ17109@ZenIV.linux.org.uk>
References: <20150701082753.GD17109@ZenIV.linux.org.uk>
 <5593A7A0.6050400@samsung.com>
 <20150701085507.GE17109@ZenIV.linux.org.uk>
 <5593CE37.4070307@samsung.com>
 <20150701184408.GF17109@ZenIV.linux.org.uk>
 <20150702032042.GA32613@ZenIV.linux.org.uk>
 <20150702041046.GG17109@ZenIV.linux.org.uk>
 <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
 <20150702075932.GI17109@ZenIV.linux.org.uk>
 <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPAsAGzJW1C-4rd9myZOsiA9dLp2d420PTePaguK=y2RWjrz2A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 02, 2015 at 11:19:03AM +0300, Andrey Ryabinin wrote:
> Besides qemu, I've also tried kvmtool with the same result. IOW I'm seeing
> this under kvmtool as well. It just takes a bit longer to reproduce
> this in kvmtool.
> 
> > The bug I suspected to be the cause of that is in tag allocation in
> > net/9p/client.c - we could end up wrapping around 2^16 with enough pending
> > requests and that would have triggered that kind of mess.  However, Andrey
> > doesn't see that test (tag wraparound in p9_client_prepare_req()) trigger.
> > BTW, was that on the run where debugging printk in p9_client_write() *did*
> > trigger?
> 
> Yes, WARN_ON_ONCE() in p9_client_prepare_req() didn't trigger,
> but debug printk in p9_client_write() *did* trigger.

Bloody wonderful...  Could you check if v9fs_write() in qemu
hw/9pfs/virtio-9p.c ever gets to
    offset = 7;
    err = pdu_marshal(pdu, offset, "d", total);
with total > count on your testcase?
