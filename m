From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Crash in NFS on 2.5.41
Date: 11 Oct 2002 04:11:23 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsy995sp10.fsf@charged.uio.no>
References: <1034280084.8583.53.camel@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zpH6-0006gB-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 19:11:36 -0700
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <1034280084.8583.53.camel@dell_ss3.pdx.osdl.net>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

>>>>> " " == Stephen Hemminger <shemminger@osdl.org> writes:

     > This happened when doing a bash completion on an NFS mounted
     > directory.  The server was (at least every other machine still
     > thinks so).

Hmm. Looks like I missed a 'kunmap()' call when I made the RPC code
copy directly into pages. Does the following fix it?

Cheers,
  Trond

--- linux-2.5.41/fs/nfs/dir.c.orig	2002-10-01 19:43:15.000000000 -0400
+++ linux-2.5.41/fs/nfs/dir.c	2002-10-10 22:09:08.000000000 -0400
@@ -130,7 +130,6 @@
 	return 0;
  error:
 	SetPageError(page);
-	kunmap(page);
 	unlock_page(page);
 	invalidate_inode_pages(inode->i_mapping);
 	desc->error = error;



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
