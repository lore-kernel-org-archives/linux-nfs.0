From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: more statd segfault
Date: Fri, 12 Sep 2003 16:39:16 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16225.27156.281198.45769@notabene.cse.unsw.edu.au>
References: <3F5CDF7D.2070608@hq.newdream.net>
	<3F6129E3.6040604@newdream.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xhbU-0001D3-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Sep 2003 23:40:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 19xhbT-0007e2-Vp
	for nfs@lists.sourceforge.net; Thu, 11 Sep 2003 23:40:24 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <michael@newdream.net>) (for <nfs@lists.sourceforge.net>) By
	note With Smtp ; Fri, 12 Sep 2003 16:40:17 +1000
To: michael <michael@newdream.net>
In-Reply-To: message from michael on Thursday September 11
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

On Thursday September 11, michael@newdream.net wrote:
> I finally tracked down the statd segfault that had been plaguing me for 
> sometime.
> 
> statd calls sunrpc code which is in libc on debian. this code loops 
> through all possible file descriptors and in my case if the number of 
> fds per process is set higher then 8096 it segfaults.

Well done.
I have just applied a patch to statd and mountd in nfs-utils so that
it forces the fd limit down to FD_SETSIZE if it is above that.  This
appears to effectively work around what is really a libc bug (I
think).

Have you reported it to the glibc maintainers?

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
