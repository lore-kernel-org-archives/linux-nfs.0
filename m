From: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
Date: Thu, 18 Sep 2008 02:32:16 -0700 (PDT)
Message-ID: <151874.61127.qm@web32601.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs list <linux-nfs@vger.kernel.org>,
	linux-kernel@vger.kernel.org
To: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from web32601.mail.mud.yahoo.com ([68.142.207.228]:48522 "HELO
	web32616.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with SMTP id S1753990AbYIRJcR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 05:32:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

----- Original Message ----

> From: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
> To: Martin Knoblauch <knobi-Ys4E+72pFW0hFhg+JK9F0w@public.gmane.org>
> Cc: linux-nfs list <linux-nfs@vger.kernel.org>; linux-kernel@vger.kernel.org
> Sent: Thursday, September 18, 2008 10:45:01 AM
> Subject: Re: [RFC][Resend] Make NFS-Client readahead tunable
> 
> Martin Knoblauch wrote:
> > ----- Original Message ----
> >
> >  
> >>
> >> I think having a tunable for client readahead is an excellent idea,
> >> although not to solve your particular problem.  The SLES10 kernel has a
> >> patch which does precisely that, perhaps Neil could post it.
> >>
> >> I don't think there's a lot of point having both a module parameter and
> >> a sysctl.
> >>
> >>    
> >
> >  Actually there is a good reason. The module parameter can be used to set the 
> new value at load time and never bother again. The sysctl is very convenient 
> when doing experiments.
> >  
> You can set module parameters after module load in
> /sys/module/$module/parameters.

 OK, one always learns new stuff :-)

> >  As Andrew already pointed out, the best solution would be a mount option.
> Yep.
> >  But that seems much more involved as my workaround patch.
> >
> >  
> Yep.

 Seeing Andrews Mails, it might be less involved that I thought :-) Will have a look.

> >> A maximum of 15 is unwise.  I've found that (at least with the older
> >> readahead mechanisms in SLES10) a multiple of 4 is required to preserve
> >> rsize-alignment of READ rpcs to the server, which helps a lot with wide
> >> RAID backends.  So in SGI we tune client readahead to 16.
> >>
> >>    
> >
> >  15 is the value that the Linux NFS client uses., at least since 2.6.3. 
> It's a silly value.

 I was not sure whether it was just arbitrary, or caused by some other internal limit. The definition made it look like it was somehow related to RPC_DEF_SLOT.

> > As it is not tunable up to today, the comment seems moot :-)  But it opens the 
> questions:
> >
> > a) should 1 be the minimum, or 0?
> >  
> Turning off client RA entirely is potentially useful.
> > b) can the backing_dev_info.ra_pages field safely be set to something higher 
> than 15?
> >  
> Yes.  Did I mention 16 ?

 You also mentioned that you do that at SGI. So, who knows whatelse there is changed :-) Anyway, thanks for the hint. 

> >  
> >> Your patch seems to have a bunch of other unrelated stuff mixed in.
> >>
> >>    
> >
> >  Yeah, someone already pointed out, that the Makefile hunk does not belong 
> there. But you say "a bunch" - anything else?
> >  
> I rapidly scrolled past some stuff about 64bit inodes.

 Ahh. Now I remember... when I implemented the module  parameter, I found that "enable_ino64" lacks a description. Yeah, should be a separate patch.

Cheers
Martin

