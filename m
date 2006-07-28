From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 000 of 2] knfsd: Don't allow bad file handles to
	cause extX to go readonly
Date: Fri, 28 Jul 2006 14:33:21 +0100
Message-ID: <20060728133321.GA439@infradead.org>
References: <20060728102713.15132.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G6ST3-0005lB-Jz
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 06:33:29 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6ST3-0001GV-Qj
	for nfs@lists.sourceforge.net; Fri, 28 Jul 2006 06:33:30 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <20060728102713.15132.patches@notabene>
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

On Fri, Jul 28, 2006 at 10:31:20AM +1000, NeilBrown wrote:
> Currently, and file handle with a bad inode number in it can cause
> ext2 to go to readonly (as it looks like a corrupted filesystem)
> and could allow remote access to ext3 special files like the journal.
> 
> These patches give ext2/3 their own get_dentry method which checks the
> inode number early before other bits of the code can be freaked out by
> it.
> 
> These are revised versions of earlier patches.  Rather than exporting
> export_iget, we open code it and simplify it slightly.  This avoids
> and extra module dependancy.

This looks much better, agreed.  Long-term we should switch ext2/ext2
to use iget_locked so we can propagate errors in finding the inode much
better.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
