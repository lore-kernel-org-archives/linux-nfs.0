From: Chris Croswhite <ccroswhite@get2chip.com>
Subject: Fwd: Exporting to Solaris with 2.4.18
Date: 26 Mar 2002 18:31:41 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1017196301.16477.36.camel@lws020.get2chip.com>
Mime-Version: 1.0
Content-Type: text/plain
Received: from [64.169.83.2] (helo=mail.get2chip.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16q3Dy-0003g4-00
	for <nfs@lists.sourceforge.net>; Tue, 26 Mar 2002 18:31:42 -0800
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

Additionally, I have no problems with all the Linux boxes (both RH6.2,
and RH7.x).  Also, I can see that the mounted point on the Slowlaris box
shows the permissions and group owenership of the remote drive.  The
server logs show:


Mar 24 05:10:01 us002 rpc.mountd: authenticated mount request from
192.168.1.76:625 for /home/customers (/home)


Am I am not sure what is happening. Any help is greatly appreciated.

TIA,

Chris

-----Forwarded Message-----

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
