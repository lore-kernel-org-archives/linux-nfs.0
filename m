From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs_refresh_inode: inode number mismatch
Date: Fri, 21 Sep 2007 16:46:37 -0400
Message-ID: <1190407597.6721.40.camel@heimdal.trondhjem.org>
References: <46E6C54F.4020100@aristoslogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chris Carlson <c.carlson@aristoslogic.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYpOg-0004jU-4M
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 13:46:46 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYpOi-0000Xw-IH
	for nfs@lists.sourceforge.net; Fri, 21 Sep 2007 13:46:51 -0700
In-Reply-To: <46E6C54F.4020100@aristoslogic.com>
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

On Tue, 2007-09-11 at 09:41 -0700, Chris Carlson wrote:
> We are running MontaVista Embedded Linux 2.4 with NetApps NFS servers as 
> the root filesystem and Linux 2.6 mounted filesystems.  A simple test 
> runs to copy files from one mount point to another (both are different 
> directories on the same NFS server mounted at differet points).
> 
> After 30 copies of a hundred files are made, the system is rebooted and 
> the test repeats.
> 
> After 2 reboots, an NFS file is created, and we get the following error 
> from the kernel:
> 
> nfs_refresh_inode: inode number mismatch
> expected (0x11/0xdacea3), got (0x11/0xb8d5e3)
> 
> We're just trying to figure out what to do to figure out what the 
> problem is.  Is there a good place to place printks or breakpoints?

It is a known problem with some versions of OnTap: they sometimes return
corrupted attribute information when an operation is denied due to a
'read-only' export option.
You should be able to fix the problem by upgrading to a more recent
version of OnTap.

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
