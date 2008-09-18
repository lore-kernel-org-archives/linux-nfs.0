From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 00:42:58 -0700 (PDT)
Message-ID: <418380.19358.qm@web32608.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32608.mail.mud.yahoo.com ([68.142.207.235]:34441 "HELO
	web32608.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752028AbYIRHm7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 03:42:59 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Andrew Morton <akpm@linux-foundation.org>
> To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> Cc: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>; linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org
> Sent: Thursday, September 18, 2008 5:13:34 AM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> On Thu, 18 Sep 2008 11:42:54 +1000 Greg Banks wrote:
> 
> > I think having a tunable for client readahead is an excellent idea,
> > although not to solve your particular problem.  The SLES10 kernel has a
> > patch which does precisely that, perhaps Neil could post it.
> > 
> > I don't think there's a lot of point having both a module parameter and
> > a sysctl.
> 
> mount -o remount,readahead=42

[root@lpsdm52 ~]# mount -o remount,readahead=42 /net/spsdms/fs13
Bad nfs mount parameter: readahead
[root@lpsdm52 ~]# mount -o readahead=42 /net/spsdms/fs13
Bad nfs mount parameter: readahead


 I assume the reply was meant to say that the correct way of introducing a modifyable readahead size is to implement it as a mount option ? :-) I considered it, but it seems to be more intrusive than the workaround patch. It also needs changes to userspace tools - correct?

Cheers
Martin

