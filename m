From: "Deac Mihai Adrian" <adydeac@hotmail.com>
Subject: A bug or misconfigured?
Date: Sun, 27 Jul 2003 00:04:54 +0300
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY2-F52l8HvNuSNGDQ00006b25@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay2-f52.bay2.hotmail.com ([65.54.247.52] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19gWDs-0006gr-00
	for <nfs@lists.sourceforge.net>; Sat, 26 Jul 2003 14:05:00 -0700
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
I am using nfs-utils Version 1.0.4. After mounting something (anything) from 
a client, i get the following line into /var/log/messages:
rpc.mountd: authenticated mount request from (null):764 for /opt/ltsp/i386 
(/opt/ltsp/i386)

On the client side seems ok... I can browse and do whatever I want, but if I 
am trying to access a second time the server it crashes. It is happening the 
same if I try to unmount the mounted directory.
Take a look:
# umount /mnt/temp/
Bad UMNT RPC: RPC: Unable to receive; errno = Connection refused
Strange: if I am using the -F flag for rpc.mountd the server doesn't fail, 
but there is still:
Jul 26 21:00:33 lightserver rpc.mountd: authenticated mount request from 
(null):801 for /opt/ltsp/i386 (/opt/ltsp/i386)
Jul 26 21:00:38 lightserver rpc.mountd: authenticated unmount request from 
(null):802 for /opt/ltsp/i386 (/opt/ltsp/i386)
Jul 26 21:01:10 lightserver rpc.mountd: authenticated mount request from 
(null):802 for /opt/ltsp/i386 (/opt/ltsp/i386)
Jul 26 21:01:11 lightserver rpc.mountd: authenticated unmount request from 
(null):805 for /opt/ltsp/i386 (/opt/ltsp/i386)
Jul 26 21:01:12 lightserver rpc.mountd: authenticated mount request from 
(null):806 for /opt/ltsp/i386 (/opt/ltsp/i386)
Jul 26 21:01:13 lightserver rpc.mountd: authenticated unmount request from 
(null):807 for /opt/ltsp/i386 (/opt/ltsp/i386)
Jul 26 21:01:14 lightserver rpc.mountd: authenticated mount request from 
(null):808 for /opt/ltsp/i386 (/opt/ltsp/i386)
Jul 26 21:01:15 lightserver rpc.mountd: authenticated unmount request from 
(null):810 for /opt/ltsp/i386 (/opt/ltsp/i386)

What can I do?
I am using Sorcerer. I compiled the same utilities on an AMD Duron and i 
dont get any of these errors. Write now I am using a Intel Celeron 1Ghz.

Best regards,
Ady Deac

_________________________________________________________________
The new MSN 8: smart spam protection and 2 months FREE*  
http://join.msn.com/?page=features/junkmail



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
