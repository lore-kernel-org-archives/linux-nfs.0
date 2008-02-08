From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: RE: nfs new_cache mechanism and older kernel
Date: Thu, 7 Feb 2008 17:01:07 -0800
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C57987CF@exchange.ZeugmaSystems.local>
References: <DDFD17CC94A9BD49A82147DDF7D545C5798775@exchange.ZeugmaSystems.local> <18347.42555.441287.802490@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "Neil Brown" <neilb@suse.de>, <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:32787 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751994AbYBHBB7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2008 20:01:59 -0500
In-Reply-To: <18347.42555.441287.802490-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil:

> -----Original Message-----
> From: Neil Brown [mailto:neilb@suse.de]
> Sent: Thursday, February 07, 2008 4:46 PM
> To: Anirban Sinha
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: nfs new_cache mechanism and older kernel
> 
> On Thursday February 7, ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org wrote:
> > Hi:
> >
> > I am wondering if there is a known issue with using the newer cache
> > mechanism in NFS (by mounting nfsd filesystem on /proc/fs/nfsd) on
an
> > older kernel like 2.6.17 built for 64 bit archs. I am observing a
> > peculiar problem. The moment nfs exportfs writes the time value from
> > time() system call to <cache>/flush, the exports entries vanishes.
> > However, when I pass smaller arbitrary values (of the order of 100s
> or
> > 10000s), the tables do not get cleared. This could be (though I am
> not
> > completely sure) due to the difference between what sys_time()
> reports
> > and what get_seconds() reports. Get_seconds() reports the seconds
> from
> > the xtime structure whereas sys_time uses do_gettimeofday() in
2.6.17
> > kenrel. But I could be wrong. Any thoughts on this?
> 
> 2.6.17 isn't that old.  The newer cache mechanism should work for any
> 2.6 kernel.
> 
> I think the different between get_seconds and sys_time should be very
> small and not really significant (I hope?).  I think there is only a
> difference when adjtime is causing time to run a little fast or a
> little slow.... I wonder if we should worry about that.

Yeah, not sure if it would make any difference. I think one of them is
the wall clock time (do_gettimeofday) and the xtime is the monotonic
time. One can be obtained from other by adding/subtracting an offset
value (wall_to_monotonic or something like that) if I recall correctly.
Why not use the same time value for both cases (if you think it could be
if some remote significance).
 
> 
> It is normal for exportfs to completely flush the in-kernel cache.
> Subsequent NFS requests will then cause an upcall to mountd which will
> add the required information to the cache.

I am wondering ... if it completely flushes the in-kernel cache as its
happening in my case, shouldn't the clients who have already mounted
their nfs filesystem, lose their mounts? In our case, we are mounting
the root fs through nfs and the moment it flushes the cache, the clients
become dead. If they happen to resend their mount request, will it not,
in that case, involve mountd? Please enlighten me. 

Ani




> 
> NeilBrown
