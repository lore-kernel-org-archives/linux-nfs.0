From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH kNFSd ] Fix d_find_alias brokenness
Date: Fri, 12 Nov 2004 11:28:21 +1100
Message-ID: <16788.933.584756.363743@cse.unsw.edu.au>
References: <20041112105449.24459.patches@notabene>
	<E1CSOoW-0006Mv-OF@notabene.cse.unsw.edu.au>
	<20041111160305.0a12aaff.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CSPGI-0003tg-1i
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 16:25:58 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CSPGH-00052l-Dd
	for nfs@lists.sourceforge.net; Thu, 11 Nov 2004 16:25:57 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: message from Andrew Morton on Thursday November 11
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

On Thursday November 11, akpm@osdl.org wrote:
> 
> Could I trouble you for a more complete description?  Which was the
> offending change, and in what way was it broken?

10 weeks ago,
 http://linux.bkbits.com:8080/linux-2.5/cset@415b3380pxf4sB97gM8ujLqDxi6GfQ

The patch was mostly right, and fixed a real problem, but missed a
bit.
It passed the job of checking if an inode had a current alias off to 
d_find_alias instead of open-coding it in d_alloc_anon.  However there
is one case where d_alloc_anon would not  return the right
dentry.  That case being when the inode was for the root of the
filesystem.
The root is a special case because it is not hashed.  All other dentries
that are not hashed are quite un-interesting: There are "unlinked" but
not yet closed.  The root of a filesystem is unhashed, but is
interesting. 

Allowing d_find_alias to return an unhashed alias for a directory
solves this problem.  It is safe because callers of d_find_alias on a
directory inode either have a name for the inode already (so finding
an unlinked directory by mistake is impossible) or will soon be
looking for a name and will drop the dentry if a name is not found.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
