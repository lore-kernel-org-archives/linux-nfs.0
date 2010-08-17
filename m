Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52923 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab0HQOyF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Aug 2010 10:54:05 -0400
From: Andi Kleen <andi@firstfloor.org>
To: "Patrick J. LoPresti" <lopresti@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-kernel <linux-kernel@vger.kernel.org>
Subject: Re: Proposal: Use hi-res clock for file timestamps
References: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
Date: Tue, 17 Aug 2010 16:54:03 +0200
In-Reply-To: <AANLkTimnyXKahtjaFeSsgcq=xMy-pP3na1jidQhZ-dt2@mail.gmail.com>
	(Patrick J. LoPresti's message of "Fri, 13 Aug 2010 11:25:49 -0700")
Message-ID: <87aaolwar8.fsf@basil.nowhere.org>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

"Patrick J. LoPresti" <lopresti@gmail.com> writes:

>
> 1) Anybody who cares about file system performance is already using
> "noatime" or "relatime", which mitigates the hit greatly.

Consider mtime.

> If the above patch is too slow for some architectures, how about
> making it a configuration option?  Call it "CONFIG_1980S_FILE_TICK",
> have it default to YES on the architectures that care and NO on
> anything remotely modern and sane.
>
> OK that's my proposal.  Bash away.

I suspect it will be a performance disaster on x86 for VFS intensive
applications on capable file systems. VFS is very performance
critical. These checks lurk on unexpected places too, e.g. on /dev
access.

Even TSC is much slower than just reading the variable.

Also you should check if the file system granuality 
even supports it, it's completely wasted on a ext3 for example.

Maybe as a optional sysctl, default to off.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
