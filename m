Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:55121 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925Ab1AENDu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Jan 2011 08:03:50 -0500
From: "Nori, Sekhar" <nsekhar@ti.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>,
        Russell King - ARM Linux <linux@arm.linux.org.uk>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        =?iso-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Marc Kleine-Budde <m.kleine-budde@pengutronix.de>,
        "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>
Date: Wed, 5 Jan 2011 18:32:58 +0530
Subject: RE: still nfs problems [Was: Linux 2.6.37-rc8]
Message-ID: <B85A65D85D7EB246BE421B3FB0FBB5930248201279@dbde02.ent.ti.com>
References: <20101230171453.GA5787@pengutronix.de>
	<1293731992.4919.5.camel@heimdal.trondhjem.org>
	<20101230191846.GB14221@pengutronix.de>
	<20110103213850.GC25121@pengutronix.de>
	<1294100558.25100.8.camel@heimdal.trondhjem.org>
	<20110105084014.GN25121@pengutronix.de>
	<20110105110517.GQ25121@pengutronix.de>
	<20110105112701.GA8638@n2100.arm.linux.org.uk>
 <4D246098.50908@pengutronix.de>
In-Reply-To: <4D246098.50908@pengutronix.de>
Content-Type: text/plain; charset="iso-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jan 05, 2011 at 17:44:16, Marc Kleine-Budde wrote:
> On 01/05/2011 12:27 PM, Russell King - ARM Linux wrote:
> > On Wed, Jan 05, 2011 at 12:05:17PM +0100, Uwe Kleine-König wrote:
> >> Hello Trond,
> >>
> >> On Wed, Jan 05, 2011 at 09:40:14AM +0100, Uwe Kleine-König wrote:
> >>> On Mon, Jan 03, 2011 at 07:22:38PM -0500, Trond Myklebust wrote:
> >>>> The question is whether this is something happening on the server or the
> >>>> client. Does an older client kernel boot without any trouble?
> >>> I will set up a boot test with 2.6.37 (for statistics) and 2.6.36 to
> >>> compare with.  If you don't consider .36 to be old enough let me now.
> >>> Once the setup is done it should be easy to test .35 (say), too.
> >>>
> >> Marc (cc'd) saw similar[1] problems with .37, when using .36.2 the
> >> problems didn't occur.  This was more reliable to trigger and he was so
> >> kind to bisect the problem.
> >>
> >> When testing v2.6.36-rc3-51-gafa8ccc init hanged.
> >> (babddc72a9468884ce1a23db3c3d54b0afa299f0 is the first bad commit with
> >> this hang.)  Commit 56e4ebf877b6043c289bda32a5a7385b80c17dee makes the
> >> "init hangs" problem the "fileid changed on tab" problem.
> >>
> >> I could only reproduce that on armv5 machines (imx27, imx28 and at91)
> >> but not on armv6 (imx35).
> > 
> > FYI, I've seen the "fileid changed" problem, and it looked like a 32-bit
> > truncation of the fileid.  It occurred several times on successive
> > reboots, so I tried to capture a tcpdump trace off the server (Linux
> > 2.6.23-rc8-ga64314e6 - its ancient because I've had issues with buggy
> > IDE drivers trying to move it forward.)  However, for the last couple
> > of weeks I've been unable to reproduce it.
> 
> We have the problem with nfs-root. From the kernel command line:
> 
> root=/dev/nfs
> nfsroot=192.168.23.2:/home/mkl/pengutronix/xxx/bsp/OSELAS.BSP-xxx-Grabowski-trunk/platform-Ronetix-PM9263/root,v3,tcp
> 
> /home/mkl/pengutronix is a link which points to a link
> /ptx/work/octopus/mkl (which is a ext3-based) which points to
> WORK_1/mkl which is also ext3-based.
> 
> The server is 2.6.32 and has been rebooted yesterday :), nfs-utils are
> 1.2.2. I make a tcpdump if needed.

I see the issue too with an ARMv5 based DM355 board with the just released
v2.6.37 tag (nfs client). I too see the issue when using bash tab completion.

Here are some logs:

fileid changed fsid 0:c: expected fileid 0x2db61d, got 0x2dad20

fileid changed fsid 0:c: expected fileid 0x100000000000, got 0x7070000000000000

I am using Fedora 8 (2.6.25 kernel) on the server side. I will try the latest
Ubuntu release on the server side and test.

Thanks,
Sekhar

