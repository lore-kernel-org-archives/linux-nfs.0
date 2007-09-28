From: corbet@lwn.net (Jonathan Corbet)
Subject: Re: A unresponsive file system can hang all I/O in the system
	on linux-2.6.23-rc6 (dirty_thresh problem?)
Date: Fri, 28 Sep 2007 07:28:52 -0600
Message-ID: <10659.1190986132@lwn.net>
References: <20070927235034.ae7bd73d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-pm <linux-pm@lists.linux-foundation.org>,
	nfs@lists.sourceforge.net, lkml <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IbFth-0001C0-Nc
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 06:28:54 -0700
Received: from vena.lwn.net ([206.168.112.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IbFtl-0004cs-N1
	for nfs@lists.sourceforge.net; Fri, 28 Sep 2007 06:28:54 -0700
In-reply-to: Your message of "Thu, 27 Sep 2007 23:50:34 PDT."
	<20070927235034.ae7bd73d.akpm@linux-foundation.org>
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

Andrew wrote:
> It's unrelated to the actual value of dirty_thresh: if the machine fills up
> with dirty (or unstable) NFS pages then eventually new writers will block
> until that condition clears.
> 
> 2.4 doesn't have this problem at low levels of dirty data because 2.4
> VFS/MM doesn't account for NFS pages at all.

Is it really NFS-related?  I was trying to back up my 2.6.23-rc8 system
to an external USB drive the other day when something flaked and the
drive fell off the bus.  That, too, was sufficient to wedge the entire
system, even though the only thing which needed the dead drive was one
rsync process.  It's kind of a bummer to have to hit the reset button
after the failure of (what should be) a non-critical piece of hardware.

Not that I have a fix to propose...:)

jon

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
