From: Jean-Eric Cuendet <jean-eric.cuendet@linkvest.com>
Subject: /smb browser
Date: Sat, 14 Sep 2002 12:55:09 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D83158D.40605@linkvest.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
To: nfs@sourceforge.net
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

Hi,
I'm in the development of my /smb browser. It will be based on:
- libsmbclient for server access
- nfs protocol between cifsd (The CIFS daemon) and the kernel.

But all the thing needs to have access at which made the current access. Ex:
- user1 reads /smb/domain/server/share/file1 (file1 further)
- The cifsd must know that the read is done by user1 for:
   - a. giving him access or not
   - b. giving the default user/group perms based on the SMB acls
But I think that the NFS server never knows which user accessed the 
file, right? It's just asked to give the uid/gid +perms of the files and 
the vfs (?) then grant/deny access to it. Right?

Which layer is the last to know which user made the file access? VFS? FS 
driver? Or is it propagated to the final destination? (NFS server, etc...)

Thanks for any help.
-jec

PS: In fact AFS do exactly that: giving the user uid/gid+perms of file 
based on the user that made the access. But afs reimplemented a *lot* of 
things: driver in the kernel, server, etc...

-- 
Jean-Eric Cuendet
Linkvest SA
Av des Baumettes 19, 1020 Renens Switzerland
Tel +41 21 632 9043  Fax +41 21 632 9090
E-mail: jean-eric.cuendet@linkvest.com
http://www.linkvest.com
--------------------------------------------------------





-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
