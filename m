From: Christian Reis <kiko@async.com.br>
Subject: umount warnings with "mountd only version 3"
Date: Sun, 26 Jan 2003 22:40:28 -0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030126224028.A26272@blackjesus.async.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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

[Last email for the day, enough bothering for a Sunday]

I've made mountd here refuse version 1 and 2 requests (rpc.mountd -N 2
-N 3), but as the FAQ itself states, we now get messages when calling
umount:

Bad UMNT RPC: RPC: Program/version mismatch; low version = 3, high version = 3

And also, showmount has stopped working:

kiko@minastirith:~$ showmount -e anthem
rpc mount export: RPC: Program/version mismatch; low version = 3, high version = 3

I was wondering if this should be fixed in the client applications
showmount and mount, or if it's a kernel issue? 

Take care,
--
Christian Reis, Senior Engineer, Async Open Source, Brazil.
http://async.com.br/~kiko/ | [+55 16] 261 2331 | NMFL


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
