From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problems with mmap consistency
Date: Fri, 17 Feb 2006 10:15:30 -0500
Message-ID: <1140189330.3612.3.camel@lade.trondhjem.org>
References: <20060217105756.GE25707@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, Andrea Arcangeli <andrea@suse.de>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FA7Ky-0000FU-ID
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 07:16:00 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FA7Kx-0001nB-3r
	for nfs@lists.sourceforge.net; Fri, 17 Feb 2006 07:16:00 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20060217105756.GE25707@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, 2006-02-17 at 11:57 +0100, Olaf Kirch wrote:
> It seems the problem is that there is still a fairly big race window
> in this code - after unmap_mapping_range returns, we're waiting for
> all dirty pages to be flushed to the server. A lot can happen while
> we wait - for instance, some other process may modify a page that
> has already been written. This modification will be lost during
> the subsequent invalidate_inode_pages2 call.
> 
> Is there a simple VM mechanism that could be used to prevent this,
> or does it need some extra logic to block a process in nfs_readpage
> while we're revalidating?

No. I believe I have discussed this with Andrea and others before.
We need to add a VM helper that will invalidate the page cache and flush
dirty pages atomically (such a thing does not yet exist).

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
