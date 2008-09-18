From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 01:38:57 -0700 (PDT)
Message-ID: <124712.40022.qm@web32602.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>,
	linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Peter zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32602.mail.mud.yahoo.com ([68.142.207.229]:46053 "HELO
	web32602.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753266AbYIRIi7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 04:38:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Andrew Morton <akpm@linux-foundation.org>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>; linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org
> Sent: Thursday, September 18, 2008 10:18:18 AM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> On Thu, 18 Sep 2008 00:42:58 -0700 (PDT) Martin Knoblauch 
> wrote:
> 
> > ----- Original Message ----
> > 
> > > From: Andrew Morton 
> > > To: Greg Banks 
> > > Cc: Martin Knoblauch ; linux-nfs list 
> ; linux-kernel@vger.kernel.org
> > > Sent: Thursday, September 18, 2008 5:13:34 AM
> > > Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> > > 
> > > On Thu, 18 Sep 2008 11:42:54 +1000 Greg Banks wrote:
> > > 
> > > > I think having a tunable for client readahead is an excellent idea,
> > > > although not to solve your particular problem.  The SLES10 kernel has a
> > > > patch which does precisely that, perhaps Neil could post it.
> > > > 
> > > > I don't think there's a lot of point having both a module parameter and
> > > > a sysctl.
> > > 
> > > mount -o remount,readahead=42
> > 
> > [root@lpsdm52 ~]# mount -o remount,readahead=42 /net/spsdms/fs13
> > Bad nfs mount parameter: readahead
> > [root@lpsdm52 ~]# mount -o readahead=42 /net/spsdms/fs13
> > Bad nfs mount parameter: readahead
> > 
> > 
> >  I assume the reply was meant to say that the correct way of introducing a 
> modifyable readahead size is to implement it as a mount option ? :-)
> 
> Yes.
>

:-)
 
> > I considered it, but it seems to be more intrusive than the workaround patch. 
> It also needs changes to userspace tools - correct?
> 
> No.  mount(8) will pass unrecognised options straight down into the
> filesystem driver.
>

 Has that always been the case, or is it a recent change? I have to support RHEL4 userland, which is not really new.
 
> It's better this way - it allows the tunable to be set on a per-mount
> basis rather than machine-wide.
>

 No question about that. I just thought it to be to complicated. Maybe I erred.
 
> Note that for block devices, readahead is a per-backing_dev_info thing
> (and a backing_dev_info has a 1:1 relationship to a disk drive for sane
> setups).  
> 
> And the NFS client maintains a backing_dev_info, which appears to map
> onto a server, so making the NFS readahead a per-backing_dev_info (ie:
> per server) thing might make sense.  Maybe nfs makes per-server information
> manipulatable down in sysfs somewhere..

 I believe Peter wanted to add per bdi stuff for nfs some time ago. Not sure what came out of it.

Cheers
Martin
