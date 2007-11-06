From: Alexander Viro <aviro@redhat.com>
Subject: Re: [PATCH] NFS: Stop sillyname renames and unmounts from
	racing
Date: Tue, 6 Nov 2007 00:15:32 -0500
Message-ID: <20071106051532.GA5397@devserv.devel.redhat.com>
References: <472C56E5.1040901@RedHat.com>
	<20071105210636.2fc72e14.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Alexander Viro <aviro@redhat.com>, Steve Dickson <SteveD@redhat.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpGnF-0002Zv-Ar
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 21:16:06 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpGnJ-0003yX-Nl
	for nfs@lists.sourceforge.net; Mon, 05 Nov 2007 21:16:11 -0800
In-Reply-To: <20071105210636.2fc72e14.akpm@linux-foundation.org>
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

On Mon, Nov 05, 2007 at 09:06:36PM -0800, Andrew Morton wrote:
> > Any objections to exporting the inode_lock spin lock?
> > If so, how should modules _safely_ access the s_inode list?

> That's going to make hch unhappy.

That's going to make me just as unhappy, especially since it's pointless;
instead of the entire sorry mess we should just bump sb->s_active to pin
the superblock down (we know that it's active at that point, so it's just
an atomic_inc(); no games with locking, etc., are needed) and call
deactivate_super() on the way out.  And deactivate_super() is exported
already.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
