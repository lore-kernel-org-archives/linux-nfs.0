From: Chip Salzenberg <chip@pobox.com>
Subject: Must statd be running before nfs client makes mounts?
Date: Sun, 15 Sep 2002 18:52:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020915225226.GI11002@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tandu.perlsupport.com ([66.220.6.226] ident=mail)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17qiGP-0006UK-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:53:13 -0700
Received: from 0-1pool60-22.nas41.philadelphia1.pa.us.da.qwest.net
	([65.129.60.22] helo=tytlal ident=mail)
	by tandu.perlsupport.com with asmtp (Exim 3.35 #1 (Debian))
	id 17qiGO-0005wF-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 15:53:12 -0700
Received: from chip by tytlal with local (Exim 3.35 #1 (Debian))
	id 17qiFe-0007Yx-00
	for <nfs@lists.sourceforge.net>; Sun, 15 Sep 2002 18:52:26 -0400
To: nfs@lists.sourceforge.net
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

I've just noticed that Debian mounts NFS filesystems from /etc/fstab
before statd starts.  Is this OK?  (And I wonder at how it's going to
try to do NFS client mounts before bind is even started, but I guess
that's a separate issue... :-))
-- 
Chip Salzenberg         - a.k.a.  -        <chip@pobox.com>
         "It furthers one to have somewhere to go."


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
