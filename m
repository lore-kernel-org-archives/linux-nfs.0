From: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>
Subject: Re: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Tue, 9 Jul 2002 14:58:53 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <agfbtk$vtn$2@main.gmane.org>
References: <E17RyHb-0005Fa-00@the-village.bc.nu> <Pine.LNX.3.95.1020709130055.377A-100000@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
   Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net,
   linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 209-166-240-202.cust.walrus.com.240.166.209.in-addr.arpa ([209.166.240.202] helo=ti3.telemetry-investments.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17S0Ch-0000GD-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 11:59:15 -0700
To: "Richard B. Johnson" <root@chaos.analogic.com>
In-Reply-To: <Pine.LNX.3.95.1020709130055.377A-100000@chaos.analogic.com>; from root@chaos.analogic.com on Tue, Jul 09, 2002 at 01:22:29PM -0400
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, Jul 09, 2002 at 01:22:29PM -0400, Richard B. Johnson wrote:
> Really? Then what is the meaning of fsync() on a read-only file-
> descriptor? You can't update the information you can't change.

Eh?  I do an fchmod() on a readonly descriptor, then I call fsync()
on that descriptor.  The inode gets sync'd to disk (with updated mode
and c_time).  So no, I don't need a writable descriptor to call fsync().
The only question is *what* gets sync'd when I call fsync() on an O_RDONLY
file-descriptor.

SUSv3 (http://www.opengroup.org/onlinepubs/007908799/xsh/fsync.html)
says "The fsync() function forces all currently queued I/O
operations associated with the file indicated by file descriptor fildes
to the synchronised I/O completion state."

It appears from this wording that the file-descriptor is *merely* a
handle referring to the inode, and that *all* outstanding I/O on the
inode [within the "system"] is performed. In other words, if I had
several different file handles referring to the same inode (but
different kernel "struct file" objects), all inode data and meta-data
updates prior to the fsync() call would be synchronized.  It doesn't
say that explicitly, but given the usual visibility rules regarding
writes, etc., that is the "natural" interpretation. [Caveat: mmap()]
To state it succinctly: if other (data or meta-data) writes are visible to 
the process doing the fsync(), they need to be sync'd too.

In the case of directories, there is no file handle "doing the writing" --
the kernel does that, so absent the ability to call fsync() on a readonly
handle to a directory, i.e. fsync(dirfd(dir)), there is no convenient way to sync
the directory contents.  Calling fsync() on every file in a directory
does not necessitate syncing the directory!

Regards,

   Bill Rugolsky


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
