From: Johan van Reijendam <jvanreij@routescience.com>
Subject: NFS unmounts fail
Date: Sun, 22 Dec 2002 16:01:17 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E06524D.1030608@routescience.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-125-123-123.dsl.pltn13.pacbell.net ([66.125.123.123] helo=obelix.jplusplus.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18QG2M-0002F0-00
	for <nfs@lists.sourceforge.net>; Sun, 22 Dec 2002 16:01:38 -0800
Received: from routescience.com (asterix.jplusplus.com [192.168.128.60])
	by obelix.jplusplus.com (8.11.6/8.11.6) with ESMTP id gBN01S102349
	for <nfs@lists.sourceforge.net>; Sun, 22 Dec 2002 16:01:28 -0800
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

Hi all,

I have been unable to find the cause and a solution for this problem

I am mounting NFS filesystems. Both the client and the server are 
running Redhat 7.3. The problem is the following :

I am able to mount a filesystem (automount or otherwise ) and can browse 
that filesystem. When I pull out of that filesystem automount will 
unmount it after a while and if manually mounted I am then able to 
manually unmount it.
However whenever I execute a binary from the mounted filesystem I am no 
longer able to unmount that filesystem. The message I get is:

umount: umount2: Device or resource busy
umount: umount: /auto/packages/binaries: device is busy

Neither lsof or fuser report any open files.

Any help is appreciated.

Johan



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
