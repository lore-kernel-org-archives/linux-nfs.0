From: Daniel Phillips <phillips@phunq.net>
Subject: Re: A unresponsive file system can hang all I/O in the system
	on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 18:27:47 -0700
Message-ID: <200709281827.48350.phillips@phunq.net>
References: <10659.1190986132@lwn.net> <1190986542.13204.10.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Jonathan Corbet <corbet@lwn.net>,
	lkml <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-pm <linux-pm@lists.linux-foundation.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbR7f-0000aD-Gl
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 18:27:59 -0700
Received: from phunq.net ([64.81.85.152] helo=moonbase.phunq.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IbR7k-0002aX-AR
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 18:28:04 -0700
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

On Friday 28 September 2007 06:35, Peter Zijlstra wrote:
> ,,,it would be grand (and dangerous) if we could provide for a
> button that would just kill off all outstanding pages against a dead
> device.

Substitute "resources" for "pages" and you begin to get an idea of how 
tricky that actually is.  That said, this is exactly what we have done 
with ddsnap, for the simple reason that our users, now emboldened by 
being able to stop or terminate the user space part, felt justified in 
expecting that the system continue as if nothing had happened, and 
furthermore, be able to restart ddsnap without a hiccup.  (Otherwise 
known as a sysop's diety-given right to kill.)

So this is what we do in the specific case of ddsnap:

   * When we detect some nasty state change such as our userspace
      control daemon disappearing on us, we go poking around and
      explicitly release every semaphore that the device driver could
      possibly wait on forever (interestingly they are all in our own
      driver except for BKL, which is just an artifact of device mapper
      not having gone over to unlock_ioctl for no good reason that I
      know of).

   * Then at the points were the driver falls through some lock thus
      released, we check our "ready" flag, and if it indicates "busted",
      proceed with wherever cleanup is needed at that point.

Does not sound like an approach one would expect to work reliably, does 
it?  But there just may be some general principle to be ferretted out 
here.  (Anyone who has ideas on how bits of this procedure could be 
abstracted, please do not hesitate to step boldly forth into the 
limelight.)

Incidentally, only a small subset of locks needed special handling as 
above.  Most can be shown to have no way to block forever, short of an 
outright bug.

I shudder to think how much work it would be to bring every driver in 
the kernel up to such a standard, particularly if user space components 
are involved, as with USB.  On the other hand, every driver fixed is 
one less driver that sucks.  The next one to emerge from the pipeline 
will most likely be NBD, which we have been working on in fits and 
starts for a while.  Look for it to morph into "ddbd", with cross-node 
distributed data awareness, in addition to perforning its current job 
without deadlocking.

Regards,

Daniel

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
