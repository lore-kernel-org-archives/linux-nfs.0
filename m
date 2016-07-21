Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:49016 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753153AbcGURPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2016 13:15:01 -0400
Date: Thu, 21 Jul 2016 13:14:58 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Thomas Gambier <thomas.gambier@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: open a file in 0100444 mode in NFSv4 may fail
Message-ID: <20160721171458.GB27148@fieldses.org>
References: <CAN63_cbcrKWYuim5NZHSfYWFXFFmcssMpiT0H2PATEu_K=FEPw@mail.gmail.com>
 <20160713132601.GA8856@fieldses.org>
 <CAN63_caHoS68rSdWeHfYxx_5bBiiqetY5NgYrL-+-Kvs=sX3RQ@mail.gmail.com>
 <20160718140915.GD11071@fieldses.org>
 <CAN63_cY=qLZ4DsyXrUuxP7cF2LO-ZxUrN6Pmtps8Y8hZZGS=Aw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN63_cY=qLZ4DsyXrUuxP7cF2LO-ZxUrN6Pmtps8Y8hZZGS=Aw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 21, 2016 at 04:54:36PM +0200, Thomas Gambier wrote:
> On Mon, Jul 18, 2016 at 4:09 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > On Mon, Jul 18, 2016 at 03:44:48PM +0200, Thomas Gambier wrote:
> >> Hello,
> >>
> >> thanks for your answer. See my comments below.
> >>
> >> On Wed, Jul 13, 2016 at 3:26 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> >> > On Mon, Jul 11, 2016 at 07:40:11PM +0200, Thomas Gambier wrote:
> >> >> Hello,
> >> >>
> >> >> I just discovered a problem with NFSv4 file system. I was using TCL
> >> >> scripts that were doing some file manipulation (mkdir, copy, ...) on
> >> >> my NFSv4 file system and sometimes the scripts failed with "permission
> >> >> denied" error.
> >> >>
> >> >> I ran strace and I found that the system call returning the error was:
> >> >> open("d1/in.txt", O_WRONLY|O_CREAT|O_TRUNC, 0100444) = -1 EACCES
> >> >> (Permission denied)
> >> >
> >> > Is that even allowed?  The open(2) man page says posix leaves behavior
> >> > in that case unspecified, and doesn't say anything I can find about
> >> > Linux behavior in this case.
> >> >
> >> You're right. I will send a mail to TCL mailing list to know why they
> >> put this flag in the open call.
> >>
> >> > I guess it would be nicer for client or server to do something
> >> > predictable, though.  First steps might be to confirm what happens other
> >> > filesystems, then do a network trace (watch the traffic in wireshark) to
> >> > see if it's the client rejecting this open, or the client passing
> >> > through that bit in the mode and the server returning the error.
> >>
> >> I agree. For other filesystem, I only tested with ext4 which works
> >> fine. Let me know if you want me to test specific filesystems.
> >>
> >> I attach the wireshark capture of a test with 8 open call working fine
> >> and the 9th one failing. For me, it seems the activity on the network
> >> is exactly the same for the failing case (same call from client to
> >> server and same answer from server to client). It would mean that the
> >> client itself is messing things up...
> >
> > Agreed, sounds like the client's only deciding to fail the open after
> > the OPEN call to the server succeeds.
> >
> > Unfortunately, the client open logic is (necessarily) pretty
> > complicated--a few minutes digging around wasn't enough for me to figure
> > uot where the error's coming from.
> >
> 
> I'm not sure if I can help... I don't know the NFS source code at all.
> I can do more tests if you need, though.

It doesn't look like a high priority based just on what we know
(slightly odd behavior in an undefined case), so I think we'll just have
to leave it at that until somebody gets curious.  Thanks for the report.

--b.
