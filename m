From: "Rongqing \"Frank\" Tu" <rtu@packetgeneral.com>
Subject: permission denied.
Date: Thu, 21 Nov 2002 15:42:11 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0211211536580.17129-100000@filer.packetgeneral.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [204.52.248.2] (helo=filer.packetgeneral.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Ey9g-0001of-00
	for <nfs@lists.sourceforge.net>; Thu, 21 Nov 2002 12:42:32 -0800
Received: from localhost (rtu@localhost)
	by filer.packetgeneral.com (8.11.6/8.11.6) with ESMTP id gALKgBp17298
	for <nfs@lists.sourceforge.net>; Thu, 21 Nov 2002 15:42:11 -0500
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

Hi All,
I am running on Linux 2.4.18-3 and try to setup a "link" nfs, but got a 
"permission denied".

a link nfs is like this:
in machine 1:  export A
in machine 2:  mount A to B and then export B
in mahcine 3:  mount B to C.

the "permission denied" occurs at the last step when I tried to mount B to 
C.

I am working on a software which needs this kind of structure, so I wonder 
if NFS support such "link" exporting and mounting?

Thanks.

Frank Tu



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
