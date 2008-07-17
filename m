From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol
 for mount.
Date: Fri, 18 Jul 2008 08:50:35 +1000
Message-ID: <18559.52411.176479.699140@notabene.brown>
References: <18556.40594.897682.204554@notabene.brown>
	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>
	<487E2BE6.5050500@RedHat.com>
	<18558.44430.959865.662592@notabene.brown>
	<487F2115.4090709@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:55101 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752451AbYGQWuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 18:50:37 -0400
In-Reply-To: message from Steve Dickson on Thursday July 17
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday July 17, SteveD@redhat.com wrote:
> > In kernels up to and including 2.6.26, mount reports "connection
> > refused" type messages as EIO rather than EPROTONOSUPPORT.
> > So detect those kernels and don't treat EIO as so fatal.
> Should we just fix the kernel to do the right thing?

Undoubtedly we should fix the kernel to do the right thing.
But some people find it much easier to upgrade user-space tools like
nfs-utils than to upgrade kernels.
We already have code in mount.nfs to cope with earlier kernels which
had less complete interfaces with userspace.
We can see this lack of distinction in error code simple as a less
complete interface in earlier kernels and treat it the same way.

I don't feel so strongly about this that I will fight to the end, but
I really think that if we can make life easier for our users with
compromising our integrity, we should.  And handling EIO differently
depending on kernel version seems to fit that goal.

NeilBrown
