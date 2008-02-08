From: Neil Brown <neilb@suse.de>
Subject: Re: nfs new_cache mechanism and older kernel
Date: Fri, 8 Feb 2008 11:45:47 +1100
Message-ID: <18347.42555.441287.802490@notabene.brown>
References: <DDFD17CC94A9BD49A82147DDF7D545C5798775@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <linux-nfs@vger.kernel.org>
To: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:56105 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762894AbYBHAps (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 Feb 2008 19:45:48 -0500
In-Reply-To: message from Anirban Sinha on Thursday February 7
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday February 7, ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org wrote:
> Hi:
> 
> I am wondering if there is a known issue with using the newer cache
> mechanism in NFS (by mounting nfsd filesystem on /proc/fs/nfsd) on an
> older kernel like 2.6.17 built for 64 bit archs. I am observing a
> peculiar problem. The moment nfs exportfs writes the time value from
> time() system call to <cache>/flush, the exports entries vanishes.
> However, when I pass smaller arbitrary values (of the order of 100s or
> 10000s), the tables do not get cleared. This could be (though I am not
> completely sure) due to the difference between what sys_time() reports
> and what get_seconds() reports. Get_seconds() reports the seconds from
> the xtime structure whereas sys_time uses do_gettimeofday() in 2.6.17
> kenrel. But I could be wrong. Any thoughts on this? 

2.6.17 isn't that old.  The newer cache mechanism should work for any
2.6 kernel.

I think the different between get_seconds and sys_time should be very
small and not really significant (I hope?).  I think there is only a
difference when adjtime is causing time to run a little fast or a
little slow.... I wonder if we should worry about that.

It is normal for exportfs to completely flush the in-kernel cache.
Subsequent NFS requests will then cause an upcall to mountd which will
add the required information to the cache.

NeilBrown
