From: "Pox Modio" <hotkey42@hotmail.com>
Subject: RPC: timed out
Date: Sat, 23 Mar 2002 00:18:48 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F129OTcmwjDgpwpJDDf0000e6e6@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Received: from f129.pav1.hotmail.com ([64.4.31.129] helo=hotmail.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16oYJH-0007KE-00
	for <nfs@lists.sourceforge.net>; Fri, 22 Mar 2002 15:18:59 -0800
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello Dear Collegues,
I need Help for mounting NFS from Client on a Server.
The installed OS is SuSE Linux 7.3.
I cant mount NFS, because i am reciving: RPC: timed out.
Ping "server" is working also printing from "client" thrue
"server".

My importing config is set with YAST2: server:/home /home/share
The "exports" File i did like this:
/home/ \
*.local.net (rw)
Before i did use fix IP-Address for the computers, this way NFS was working. 
Now i am using DHCP, because i have installed an ADSL Router with a litle 
integrated DHCP/DNS Server.
Is the "\" a valid entry?
Or what is fault?
Did i not understand something.

I did not find, where to write except to this Mailing list.

Thanks for every reply, for resolving the problem.

Have a good Time
P.M.

_________________________________________________________________
Downloaden Sie MSN Explorer kostenlos unter http://explorer.msn.de/intl.asp.


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
