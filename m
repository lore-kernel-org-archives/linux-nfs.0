From: "Nishit Shah" <nshah1001@hotmail.com>
Subject: how to make NFS server thread sleep?
Date: Sat, 17 May 2003 12:35:00 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BAY2-F32Ib61LF1g0Mc00009e18@hotmail.com>
Reply-To: nishit@ieee.org
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from bay2-f32.bay2.hotmail.com ([65.54.247.32] helo=hotmail.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Gvkg-0007el-00
	for <nfs@lists.sourceforge.net>; Sat, 17 May 2003 00:05:06 -0700
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



  Hello,


  I am trying to make NFS server sleep by giving sleep command in the NFS 
server READ procedure.

However,doing so causes the server to stop responding to all clients.

How do I make a single server thread go to sleep so that any other client 
can continue interacting with  the server?

Thank You,
Nishit.

_________________________________________________________________
Bridge gaps. Reconnect with old friends. http://www.batchmates.com/msn.asp 
On batchmates.com



-------------------------------------------------------
This SF.net email is sponsored by: If flattening out C++ or Java
code to make your application fit in a relational database is painful, 
don't do it! Check out ObjectStore. Now part of Progress Software.
http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
