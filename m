From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: [linux-pm] Re: A unresponsive file system can hang all
 I/O in the system on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 12:45:41 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0709281244250.4336-100000@iolanthe.rowland.org>
References: <1190986542.13204.10.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jonathan Corbet <corbet@lwn.net>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-pm <linux-pm@lists.linux-foundation.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbIyI-0007cX-Om
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:45:46 -0700
Received: from iolanthe.rowland.org ([192.131.102.54])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1IbIyK-0006Ha-RP
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 09:45:51 -0700
In-Reply-To: <1190986542.13204.10.camel@twins>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Fri, 28 Sep 2007, Peter Zijlstra wrote:

> On Fri, 2007-09-28 at 07:28 -0600, Jonathan Corbet wrote:

> > Is it really NFS-related?  I was trying to back up my 2.6.23-rc8 system
> > to an external USB drive the other day when something flaked and the
> > drive fell off the bus.  That, too, was sufficient to wedge the entire
> > system, even though the only thing which needed the dead drive was one
> > rsync process.  It's kind of a bummer to have to hit the reset button
> > after the failure of (what should be) a non-critical piece of hardware.
> > 
> > Not that I have a fix to propose...:)
> 
> the per bdi work in -mm should make the system not drop dead.
> 
> Still, would a remove,re-insert of the usb media end up with the same
> bdi? That is, would it recognise as the same and resume the transfer.

Removal and replacement of the media might work.  I have never tried 
it.

But Jon described removal of the device, not the media.  Replacing the 
device definitely will not work.

Alan Stern


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
