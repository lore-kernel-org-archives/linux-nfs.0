From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 01:18:18 -0700
Message-ID: <20080918011818.950901ff.akpm@linux-foundation.org>
References: <418380.19358.qm@web32608.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58999 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbYIRISZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 04:18:25 -0400
In-Reply-To: <418380.19358.qm-1+WuAixcP4WvuULXzWHTWIglqE1Y4D90QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 18 Sep 2008 00:42:58 -0700 (PDT) Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org> wrote:

> ----- Original Message ----
> 
> > From: Andrew Morton <akpm@linux-foundation.org>
> > To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> > Cc: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>; linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org
> > Sent: Thursday, September 18, 2008 5:13:34 AM
> > Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> > 
> > On Thu, 18 Sep 2008 11:42:54 +1000 Greg Banks wrote:
> > 
> > > I think having a tunable for client readahead is an excellent idea,
> > > although not to solve your particular problem.  The SLES10 kernel has a
> > > patch which does precisely that, perhaps Neil could post it.
> > > 
> > > I don't think there's a lot of point having both a module parameter and
> > > a sysctl.
> > 
> > mount -o remount,readahead=42
> 
> [root@lpsdm52 ~]# mount -o remount,readahead=42 /net/spsdms/fs13
> Bad nfs mount parameter: readahead
> [root@lpsdm52 ~]# mount -o readahead=42 /net/spsdms/fs13
> Bad nfs mount parameter: readahead
> 
> 
>  I assume the reply was meant to say that the correct way of introducing a modifyable readahead size is to implement it as a mount option ? :-)

Yes.

> I considered it, but it seems to be more intrusive than the workaround patch. It also needs changes to userspace tools - correct?

No.  mount(8) will pass unrecognised options straight down into the
filesystem driver.

It's better this way - it allows the tunable to be set on a per-mount
basis rather than machine-wide.

Note that for block devices, readahead is a per-backing_dev_info thing
(and a backing_dev_info has a 1:1 relationship to a disk drive for sane
setups).  

And the NFS client maintains a backing_dev_info, which appears to map
onto a server, so making the NFS readahead a per-backing_dev_info (ie:
per server) thing might make sense.  Maybe nfs makes per-server information
manipulatable down in sysfs somewhere..

