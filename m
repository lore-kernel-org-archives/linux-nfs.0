From: "Jean-Eric Cuendet" <Jean-Eric.Cuendet@linkvest.com>
Subject: NFS server
Date: Wed, 11 Sep 2002 12:13:45 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <61FEFD6522F0F142B36E3F6CE511A4F01D37F0@hermes.linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Return-path: <nfs-admin@lists.sourceforge.net>
To: <nfs@sourceforge.net>
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


Hi,
In an NFS server, does it know the user that makes the request?
Ex:
- user1 access /mnt/remote/file1 (mounted on NFS)
- The kernel asks the NFS server for this file
- The NFS server get a request for the file1
Does the server know (or is it able to know) which user (user1 in the =
case) tried to access the file?

The goal would be to give user/group ownership dependent on the user =
accessing it.
Ex:=20
- user1 access /mnt/Remote/file1 and got perms: user1,rx / guser1,rx
- user2 access /mnt/Remote/file1 and got perms: user2,rwx / guser2,---
This based on real ACLs of the file on the server (mainly SMB ACLs).

Thanks.
-jec



-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
