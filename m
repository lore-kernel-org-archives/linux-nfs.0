From: Matthias Kittner <kittner@vrcom.de>
Subject: Linux client network performance
Date: Wed, 25 Jun 2003 10:56:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EF963D8.9010204@vrcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gabor.vrcom.de ([146.140.24.3])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19V65H-0008JG-00
	for <nfs@lists.sourceforge.net>; Wed, 25 Jun 2003 01:56:55 -0700
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

[I am not a subscriber, please CC to my eMail!]

Hello,

we have the following problem:

- 2 linux clients:
	2.4.19-16mdk
	2.4.20
- Solaris NFS-Server (nfs.server 1.21)
	SunOS 5.7

If we compile on one of the linux machines sometimes in this compile 
process the whole network hangs resp. is so slow that one can wait 
between 10s or 2min to finish a "ls".

"snoop" at the nfs-server machine show very/very much "UDP continuation" 
traffic between the linux client and the solaris server. Killing the 
compile process stops this messages.

Can anyone help us? Is this a configuration problem or a bug?

Regards,
Matthias



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
