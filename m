From: Sampo Nurmentaus <audiopoppi-13@audioriders.fi>
Subject: Remote system error
Date: Mon, 8 Jul 2002 17:10:15 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.33.0207081702150.5299-100000@localhost>
Reply-To: <sampo.nurmentaus@audioriders.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cs150121.pp.htv.fi ([213.243.150.121])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RZDh-0002Ce-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Jul 2002 07:10:29 -0700
Received: from [120.100.100.14] (rhols129.adsl.netsonic.fi [194.29.198.129])
	by cs150121.pp.htv.fi (8.11.6/8.11.6) with ESMTP id g68EAPI09819
	for <nfs@lists.sourceforge.net>; Mon, 8 Jul 2002 17:10:25 +0300
To: <nfs@lists.sourceforge.net>
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



Hello folks!

I have just portted nfs daemon to our embedded linux
board running 2.4.14 kernel.

All the stuff (portmap, mountd, nfsd, statd, lockd and exportfs)
run all just fine with /var/lib/nfs on ramdisk and
/etc on flash.

Now when I try to mount an exported dir to my laptop
I get this wierd error msg: 'RPC: Remote system error'

?!?

All I know is that it is not about the permissions since in syslock it
says that mount request is authenticated and if I remove the line in
question from /etc/exports the responce is 'Permission denied' as it
should be.


Any ideas?


Thanks in advance,

Sampo Nurmentaus,
Software developers,
www.audioriders.fi



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Oh, it's good to be a geek.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
