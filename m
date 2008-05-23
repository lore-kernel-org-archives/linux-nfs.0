From: "Ajay Gupta (akgupta)" <akgupta-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [NFS] Error ESTALE require Linux NFS client to reboot?
Date: Fri, 23 May 2008 09:53:16 -0400
Message-ID: <C71BB463D9B1EF4E8F55E0737EF558B504D30ADB@xmb-rtp-209.amer.cisco.com>
References: <C71BB463D9B1EF4E8F55E0737EF558B504D30ABC@xmb-rtp-209.amer.cisco.com>
	<4836CB16.6040909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Peter Staubach" <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:40461 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753151AbYEWNxu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 May 2008 09:53:50 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JzXiO-0000Ww-0U
	for linux-nfs@vger.kernel.org; Fri, 23 May 2008 23:53:48 +1000
In-Reply-To: <4836CB16.6040909@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks Peter!!

Sorry typo... I meant Linux kernel version 2.6.12. 

Is there any pointer where I can get more info about recovering from
ESTALE error at client?

Regards,
Ajay

-----Original Message-----
From: Peter Staubach [mailto:staubach@redhat.com] 
Sent: Friday, May 23, 2008 9:48 AM
To: Ajay Gupta (akgupta)
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Error ESTALE require Linux NFS client to reboot?

Ajay Gupta (akgupta) wrote:
> Hi,
>  
> I have few questions regarding ESTALE error which Linux NFS client 
> reports to application - is there any scenario where this will require

> a NFS client reboot ? Does Linux kernel version 2.6.Le or after can 
> fully recover from ESTALE error and not require client to reboot? What

> application should do if encountered ESTALE error to gracefully
recover ?
>

Most of this depends upon where the ESTALE error was encountered in the
file system and what the application was doing with that object.  It
also depends upon what semantics are desired for "recovering".

In general though, a client reboot is not required.  Finding a way to
umount and mount again or to close and reopen the file will lead to
things clearing up.

By the way, which Linux kernel version is 2.6.Le?

    Thanx...

       ps

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

