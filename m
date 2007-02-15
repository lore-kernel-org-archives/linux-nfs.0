From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.19.2 nfs BUG: warning
	at	mm/truncate.c:398/invalidate_inode_pages2_range()
Date: Thu, 15 Feb 2007 11:06:01 -0800
Message-ID: <1171566361.7333.34.camel@heimdal.trondhjem.org>
References: <20070215185228.GA3181@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>,
	linux-kernel@vger.kernel.org
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HHlvp-00010r-Lw
	for nfs@lists.sourceforge.net; Thu, 15 Feb 2007 11:06:14 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+i1cZ2ZwyLbmQMKL4l4F8qtRahXG9iDUM=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HHlvq-0007oC-11
	for nfs@lists.sourceforge.net; Thu, 15 Feb 2007 11:06:15 -0800
In-Reply-To: <20070215185228.GA3181@janus>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2007-02-15 at 19:52 +0100, Frank van Maarseveen wrote:
> FYI,
> 
> Just captured this one, I'm not sure it's NFS at fault because I saw
> at least another AIO related mm/truncate.c:398 report with a totally
> different stack trace.
> 
> The machine seems still running happily, as usual with a considerable
> load. kernel is tainted by fglrx.
> 
> kernel: BUG: warning at mm/truncate.c:398/invalidate_inode_pages2_range()
> kernel:  [<c0104897>] dump_trace+0x227/0x240
> kernel:  [<c010498f>] show_trace_log_lvl+0x2f/0x50
> kernel:  [<c01049d7>] show_trace+0x27/0x30
> kernel:  [<c0104b06>] dump_stack+0x26/0x30
> kernel:  [<c015a495>] invalidate_inode_pages2_range+0x305/0x310
> kernel:  [<c015a4c1>] invalidate_inode_pages2+0x21/0x30
> kernel:  [<c01f7aa8>] nfs_revalidate_mapping+0x98/0x180
> kernel:  [<c01f5726>] nfs_file_read+0x46/0xb0
> kernel:  [<c017441e>] do_sync_read+0xde/0x130
> kernel:  [<c0174511>] vfs_read+0xa1/0x1b0
> kernel:  [<c0174947>] sys_read+0x47/0x70
> kernel:  [<c0103387>] syscall_call+0x7/0xb
> kernel:  [<b7ec0cbe>] 0xb7ec0cbe
> kernel:  =======================

That is a known issue. The warning was bogus after we fixed up the NFS
client to handle the case where invalidate_inode_pages2() returns and
error, and so the warning was removed in 2.6.20.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
