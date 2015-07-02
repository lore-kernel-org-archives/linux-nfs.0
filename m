Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49487 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480AbbGBH7j (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jul 2015 03:59:39 -0400
Date: Thu, 2 Jul 2015 08:59:33 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>,
        Eric Van Hensbergen <ericvh@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: running out of tags in 9P (was Re: [git pull] vfs part 2)
Message-ID: <20150702075932.GI17109@ZenIV.linux.org.uk>
References: <20150701062752.GC17109@ZenIV.linux.org.uk>
 <55939BE3.6040902@samsung.com>
 <20150701082753.GD17109@ZenIV.linux.org.uk>
 <5593A7A0.6050400@samsung.com>
 <20150701085507.GE17109@ZenIV.linux.org.uk>
 <5593CE37.4070307@samsung.com>
 <20150701184408.GF17109@ZenIV.linux.org.uk>
 <20150702032042.GA32613@ZenIV.linux.org.uk>
 <20150702041046.GG17109@ZenIV.linux.org.uk>
 <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAPAsAGzZVy3-D4J1ZGsUZU4RRQ36NtprZg_Uvfi5=46=1_rpWA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 02, 2015 at 10:50:05AM +0300, Andrey Ryabinin wrote:

> >> and see if it triggers.  I'm not sure if failing with ENOMEM is the
> >> right response (another variant is to sleep there until the pile
> >> gets cleaned or until we get killed), and WARN_ON_ONCE() is definitely
> >> not for the real work, but it will do for confirming that this is what
> >> we are hitting.
> >
> 
> Apparently, I'm seeing something else. That WARN_ON_ONCE didn't trigger.

Summary for those who'd missed the beginning of the thread: what we are
seeing is p9_client_write() issing TWRITE and getting RWRITE in reply
(tags match, packets look plausible) with count in RWRITE way more than
that in TWRITE.

IOW, we are telling the server to write e.g. 93 bytes and are getting told
that yes, the write had been successful - all 4096 bytes of it.

qemu virtio-9p for server; from my reading of qemu side of things, it can't
be sending reply with count greater than that in request.

The bug I suspected to be the cause of that is in tag allocation in
net/9p/client.c - we could end up wrapping around 2^16 with enough pending
requests and that would have triggered that kind of mess.  However, Andrey
doesn't see that test (tag wraparound in p9_client_prepare_req()) trigger.
BTW, was that on the run where debugging printk in p9_client_write() *did*
trigger?
