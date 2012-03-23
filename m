Return-Path: linux-nfs-owner@vger.kernel.org
Received: from www262.sakura.ne.jp ([202.181.97.72]:53921 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750913Ab2CWFY7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Mar 2012 01:24:59 -0400
Message-Id: <201203230523.q2N5Nhn4068469@www262.sakura.ne.jp>
Subject: Re: [RFC 4/4] {RFC} kmod.c: Add new call_usermodehelper_timeout()API
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: bharrosh@panasas.com
Cc: oleg@redhat.com, akpm@linux-foundation.org, rjw@sisk.pl,
        keyrings@linux-nfs.org, linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        sbhamare@panasas.com, dhowells@redhat.com, eparis@redhat.com,
        srivatsa.bhat@linux.vnet.ibm.com, kay.sievers@vrfy.org,
        jmorris@namei.org, ebiederm@xmission.com, gregkh@linuxfoundation.org,
        rusty@rustcorp.com.au, tj@kernel.org, rientjes@google.com
MIME-Version: 1.0
Date: Fri, 23 Mar 2012 14:23:43 +0900
References: <4F691059.30405@panasas.com> <4F691383.5040506@panasas.com> <4F6A92FC.6060702@panasas.com> <20120322142758.GA12370@redhat.com> <4F6B789C.8020201@panasas.com> <201203230716.GFE32712.StOJOVFHMQOFFL@I-love.SAKURA.ne.jp> <4F6C0092.1010901@panasas.com>
In-Reply-To: <4F6C0092.1010901@panasas.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Boaz Harrosh wrote:
> That's fine. I will fail totally gracefully, and nothing will happen. I like this
> example if the system is under heavy load and there is no memory and the
> iscsi auto-login takes more then 15 second (Settable by module param) then I'd
> rather fail the login and revert to plain NFS-MDS IO, instead of the direct osd-target
> IO. Believe me.

So, race with timeout causes no inconsistency to the kernel.
Then, it will be no problem to have timeout-able version.

> >> I don't want any chance of D stating IO operations.
> >> (My code is in the IO path, either fsync or write-back. There is not
> >>  always a killable target)
> > 
> > Then, isn't UMH_NO_WAIT better than UMH_WAIT_PROC?
> > 
> No I need to wait for the application to finish the iscsi login before
> I can continue IO to the target. Otherwise what's the point.

Your code which launches usermodehelper is in the I/O path, isn't it?
Then, don't you need to use GFP_NOFS rather than GFP_KERNEL?
http://lists.infradead.org/pipermail/linux-mtd-cvs/2007-October/005937.html

I'm not familiar with GFP_* flags usage. Can somebody clarify when we need to
use GFP_NOFS rather than GFP_KERNEL by enumerating the name of function (e.g.
xxxfs_writepage()) and/or the name of locks (e.g. xxx_mutex)? I've asked this
in the past http://www.spinics.net/lists/linux-fsdevel/msg30248.html but
explanation with actual function/variable names is easier to understand.
