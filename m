From: "Peter Albertsson" <Peter.Albertsson@naturesown.se>
Subject: mount: RPC: Timed out
Date: Thu, 14 Aug 2003 19:08:37 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000601c36286$b6e4e620$8c35a8c0@peter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [212.209.185.222] (helo=intranet.naturesown.se)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nLaj-0004zW-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 10:08:49 -0700
Received: from peter (192.168.53.140) by intranet.naturesown.se with ESMTP
 (Eudora Internet Mail Server 3.1.2) for <nfs@lists.sourceforge.net>;
 Thu, 14 Aug 2003 19:08:46 +0200
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Could someone please help me with the following problem.

This is what happens when I try to mount a nfs share on a client.


[root@frankenstein3 etc]# mount -t nfs 192.168.53.200:/var/www /var/www
mount: RPC: Timed out
[root@frankenstein3 etc]#

If I mount the share on the same server it works fine.


Netstat on client:

[root@frankenstein3 root]# netstat -n
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address           Foreign Address
State
tcp        0      0 192.168.53.136:895      192.168.53.200:111
TIME_WAIT

On server no connections show up at all.

I've seen this problem being discussed on this mailing list and some
other places, but I haven't found a solution.

The server is running on Red Hat 9.0.

Thanks,
  // Peter




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
