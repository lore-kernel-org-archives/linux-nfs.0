Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58189 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933751Ab3GET1z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 15:27:55 -0400
Date: Fri, 5 Jul 2013 15:27:49 -0400
To: Harald Dunkel <harald.dunkel@aixigo.de>
Cc: Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
        linux-nfs@vger.kernel.org
Subject: Re: Linux 3.7 + Sun solaris 10: Problems when reading dir from
 application
Message-ID: <20130705192749.GB8288@fieldses.org>
References: <201302041112.03587.ulrich.gemkow@ikr.uni-stuttgart.de>
 <201302042124.10739.ulrich.gemkow@ikr.uni-stuttgart.de>
 <20130705082740.3df4245a@dpcl082.ac.aixigo.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130705082740.3df4245a@dpcl082.ac.aixigo.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 05, 2013 at 08:27:40AM +0200, Harald Dunkel wrote:
> Hi Ulrich,
> 
> On Mon, 4 Feb 2013 21:24:08 +0100
> Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de> wrote:
> 
> > Hello,
> > 
> > please allow a followup of my own on this:
> > 
> > On Monday 04 February 2013 11:12:03 Ulrich Gemkow wrote:
> > > Hello,
> > > 
> > > we upgraded our fileserver from Linux 3.2 to linux 3.7.6 and now have
> > > problems when accessing our nfs-mounted user homes from some sun-
> > > applications (i.e. Adobe Framemaker):
> > > 
> > > In the applications file open box, no files are displayed. When entering
> > > the filename by path, the file can be opened. So it seems some kind of
> > > dir enumeration which is used by the sun applications is broken.
> > > 
> > > Other programs on the sun like ls work as before and show all files.
> > > 
> > > We are using NFSv3 (and cannot switch to v4). Our sun is a very old
> > > machine running Sun Solaris 10.
> > 
> > When mounting with vers=2 on the sun (using NFSv2) the files
> > "reappear", so this is a clear regression in NFSv3 between
> > Linux 3.2 and Linux 3.7.

And the *only* thing you change is the kernel version, not nfs-utils or
anything else in userspace?

> Have you considered upgrading your Solaris version? I had tons 
> of problems with NFS on Solaris10u6 and 10u8, including unresponsive
> mount points, problems with delegations (esp. in the users' .ssh
> directories and .Xauthority files) and strange "permission 
> denied" error messages for some ACL feature I never configured on 
> the server. 
> 
> NFS in Solaris 10u10 works much better together with Linux. I
> haven't tried Solaris 11.
> 
> My servers run Squeeze and the Linux kernel from the squeeze-
> backports repository (3.2.0-0.bpo.4-amd64).
> 
> > Maybe this can be fixed. I will be happy to give more info
> > if someone is interested.

Most interesting would probably be packet captures in both the "good"
and "bad" cases; so, something like:

	tcpdump -s0 -wtmp.pcap

then reproduce the problem, then kill tcpdump and send tmp.pcap.

(And/or take a look at it yourself with "wireshark tmp.pcap", and there
may be something obvious that jumps out even to a non-expert.)

--b.
