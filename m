From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] mmap corruption
Date: 05 Apr 2003 00:01:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsistt7wip.fsf@charged.uio.no>
References: <3E8DDB13.9020009@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,  linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191ZFD-0001JN-00
	for <nfs@lists.sourceforge.net>; Fri, 04 Apr 2003 14:01:07 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3E8DDB13.9020009@RedHat.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Steve Dickson <SteveD@redhat.com> writes:

     > The Cause: Memory mapped pages were not being flushed out in a
     > timely manner. When a file is about to truncated (up or down),
     > nfs_writepage() is called (by filemap_fdatasync()) to flush out
     > dirty pages. When this done asynchronously, nfs_writepage()
     > will (indirectly) call nfs_strategy().  nfs_strategy() wants to
     > send groups of pages (in this case 4 pages). Now in the error
     > case, only one page was dirty so it was *not* flushed out.
     > Eventually that page would be flushed (by kupdate) but it was
     > too late because the file size had already change due to a
     > second truncation.

That simply doesn't ring true. The nfs_wb_all() immediately after the
call to filemap_fdatasync() should ensure that *all* scheduled writes
will flushed out.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
