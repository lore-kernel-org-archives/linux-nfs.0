From: Chris Croswhite <ccroswhite@get2chip.com>
Subject: Exporting to Solaris with 2.4.18
Date: 26 Mar 2002 17:49:25 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1017193765.16477.31.camel@lws020.get2chip.com>
Mime-Version: 1.0
Content-Type: text/plain
Received: from [64.169.83.2] (helo=mail.get2chip.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16q2Z5-0006U8-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 17:49:27 -0800
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

Having difficulties getting Slowlaris boxes to work with my linux file
server.  When I 'ls' the mount point I get nothing.  If I use the NIS
tables and I try to cd into the dir (even as the owner of the dir), I
get permission denied.  

I manually mounted the drive like this:

mount -F nfs -o soft us002:/home/customers /customers

ls of the this mount point shows nothing.

The linux box is a stock RH7.2 upgraded to 2.4.18 kernel. I am running
with "--no-nfs-version 3" option. The export table is simple:
/home/customers	*(rw)


Any help would be greatly appreciated.

TIA,
Chris Croswhite


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
