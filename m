From: Christoph Dohmen <chdohmen@gmx.de>
Subject: mysterious NFS-behaviour
Date: Thu, 8 May 2003 10:17:16 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <03May8.101130cest.115214@gw.cae-gmbh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.cae-gmbh.de ([195.124.148.2] helo=cae-gmbh.de)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Dgaq-0006TG-00
	for <nfs@lists.sourceforge.net>; Thu, 08 May 2003 01:17:32 -0700
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

Hi folks,

I was told about a very mysterious behaviour of a NFS-system. But I could not 
explain what's happening. So, maybe someone of this list is able?!

Well, there's a system running suse linux 7.2 with kernel 2.4.4 on a 
nfs-server using software-raid for the exported directory. More than 60 
clients (also suse 7.2 with 2.4.4) mount this export.
So the behaviour is the following:
I have one client and open four terminales.
In the first terminal (local) I do a mkdir foo in the mounted directory
In the second terminal (local) I do a ls in the mounted directory and I get an 
I/O-error
In the third terminal (ssh on the nfs-server) I can see the created directory.
In the fourth terminal (ssh on another client) I can see the created directory 
after about one or two seconds.

So, what's going on? Is there a misconfiguration? Are 60 clients too many??

thanks

Chris
-- 
Christoph Dohmen                    ChDohmen@gmx.de


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
