From: Alejandro Rios Garcia <arios2@prodigy.net.mx>
Subject: About NFS Configuration.
Date: Sat, 05 Apr 2003 16:18:19 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1049588300.1454.14.camel@ws>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dfproxy06.prodigy.net.mx ([148.235.168.22] helo=smtp.prodigy.net.mx)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 191vwc-0006h5-00
	for <nfs@lists.sourceforge.net>; Sat, 05 Apr 2003 14:15:26 -0800
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


Hi!

I have not enought experience using NFS but I sucessfully installed it
as following:
I'm running a server with Suse 8.0 Pro
also I'm running a workstation with Suse 8.0 Pro

I created user "user1" on my server, also I created "user1" on my
workstation. So I had:
//Server/home/user1
//WS/home/user1

After a while I noticed that my information was messed, so, I deleted
//ws/home/user1, I exported //server/home/user1 to my //ws/home/user1
Now I am able to do everything from here, but sometimes when I restart
my computer (ws) it's shutdown procedure reports that NFS service was
not able to shutdown sucessfully"
Up to now I haven't loss information but I want to prevent this

Thanks in advance
Alejandro



-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
