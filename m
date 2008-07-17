From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] mount: enable retry for nfs23 to set the correct protocol
 for mount.
Date: Thu, 17 Jul 2008 06:38:13 -0400
Message-ID: <487F2115.4090709@RedHat.com>
References: <18556.40594.897682.204554@notabene.brown>	<76bd70e30807150811p56feb02bo6e4a366d5577b398@mail.gmail.com>	<487E2BE6.5050500@RedHat.com> <18558.44430.959865.662592@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chucklever@gmail.com, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34063 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756524AbYGQKit (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jul 2008 06:38:49 -0400
In-Reply-To: <18558.44430.959865.662592-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Neil Brown wrote:
> On Wednesday July 16, SteveD@redhat.com wrote:
>>>>  Enable retry if the mount call returns EIO, as that is what happens
>>>>    if the UDP requests to portmap get no response.
>>> I would rather see this one addressed in the kernel.  I think the EIO
>>> return is a kernel bug.  If the server doesn't support a particular
>>> transport protocol for portmap, mountd, or NFS, the mount(2) system
>>> call should always return EPROTONOSUPPORT.
>> Since EIO has so many meanings... I think it should stay as a fatal 
>> error as well...
>>
> 
> That would be best.  But the reality is that there are kernels in the
> wild where -EIO indicates and error that isn't really fatal.
Yeah I know... and thats the problem.. EIO is basically a catch all errno.. 

> 
> We already do kernel-detection in mount.  How about extending it like
> this?
> 
> Thanks,
> NeilBrown
> 
> From: Neil Brown <neilb@suse.de>
> Date: Thu, 17 Jul 2008 12:23:03 +1000
> Subject: [PATCH] mount: Recognised EIO from early kernels as possibly indicating a protocol error.
> 
> In kernels up to and including 2.6.26, mount reports "connection
> refused" type messages as EIO rather than EPROTONOSUPPORT.
> So detect those kernels and don't treat EIO as so fatal.
Should we just fix the kernel to do the right thing?

steved.
