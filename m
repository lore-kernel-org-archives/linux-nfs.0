Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.aixigo.de ([80.149.209.52]:60644 "EHLO mail.aixigo.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751430Ab3GEGrr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 02:47:47 -0400
Date: Fri, 5 Jul 2013 08:27:40 +0200
From: Harald Dunkel <harald.dunkel@aixigo.de>
To: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Linux 3.7 + Sun solaris 10: Problems when reading dir from
 application
Message-ID: <20130705082740.3df4245a@dpcl082.ac.aixigo.de>
In-Reply-To: <201302042124.10739.ulrich.gemkow@ikr.uni-stuttgart.de>
References: <201302041112.03587.ulrich.gemkow@ikr.uni-stuttgart.de>
	<201302042124.10739.ulrich.gemkow@ikr.uni-stuttgart.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Ulrich,

On Mon, 4 Feb 2013 21:24:08 +0100
Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de> wrote:

> Hello,
> 
> please allow a followup of my own on this:
> 
> On Monday 04 February 2013 11:12:03 Ulrich Gemkow wrote:
> > Hello,
> > 
> > we upgraded our fileserver from Linux 3.2 to linux 3.7.6 and now have
> > problems when accessing our nfs-mounted user homes from some sun-
> > applications (i.e. Adobe Framemaker):
> > 
> > In the applications file open box, no files are displayed. When entering
> > the filename by path, the file can be opened. So it seems some kind of
> > dir enumeration which is used by the sun applications is broken.
> > 
> > Other programs on the sun like ls work as before and show all files.
> > 
> > We are using NFSv3 (and cannot switch to v4). Our sun is a very old
> > machine running Sun Solaris 10.
> 
> When mounting with vers=2 on the sun (using NFSv2) the files
> "reappear", so this is a clear regression in NFSv3 between
> Linux 3.2 and Linux 3.7.
> 

Have you considered upgrading your Solaris version? I had tons 
of problems with NFS on Solaris10u6 and 10u8, including unresponsive
mount points, problems with delegations (esp. in the users' .ssh
directories and .Xauthority files) and strange "permission 
denied" error messages for some ACL feature I never configured on 
the server. 

NFS in Solaris 10u10 works much better together with Linux. I
haven't tried Solaris 11.

My servers run Squeeze and the Linux kernel from the squeeze-
backports repository (3.2.0-0.bpo.4-amd64).

> Maybe this can be fixed. I will be happy to give more info
> if someone is interested.
> 

That would be nice.


Good luck
Harri
