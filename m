From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: NFS3PROC_ACCESS bug in 2.6.x
Date: Sun, 6 Feb 2005 19:39:13 +0100
Message-ID: <20050206183913.GA28176@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CxrJa-0005qa-B9
	for nfs@lists.sourceforge.net; Sun, 06 Feb 2005 10:39:22 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CxrJZ-00042K-LW
	for nfs@lists.sourceforge.net; Sun, 06 Feb 2005 10:39:22 -0800
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Both server and client are the same machine and run unpatched
2.6.11-rc3. /proc/mounts says:

localhost:/loc/nfstest /mnt2 nfs rw,sync,v3,rsize=32768,wsize=32768,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,udp,noac,nolock,addr=localhost 0 0

Problem is that we should have permission to create according to the
secondary group list but apparently we don't:

$ cd /mnt2/subdir
$ ls -ld .
drwxrwx---    2 root     owner        4096 Feb  6 18:39 .
$ id
uid=363(fvm) gid=215(sec) groups=215(sec),3972(owner),..
						^^^
$ strace -e mkdir /bin/mkdir aap
mkdir("aap", 0777)                      = -1 EACCES (Permission denied)
/bin/mkdir: cannot create directory `aap': Permission denied
$ ls -al
total 8
drwxrwx---    2 root     owner        4096 Feb  6 18:39 .
drwxr-xr-x    7 root     root         4096 Feb  6 18:39 ..
$ >pipo
bash: pipo: No such file or directory
$ strace touch pipo

	...
	open("pipo", O_WRONLY|O_NONBLOCK|O_CREAT|O_NOCTTY|O_LARGEFILE, 0666) = -1 EACCES (Permission denied)

	(I give up, lets go back to the server side)

$ cd /loc/nfstest/subdir
$ ls -al
total 8
drwxrwx---    2 root     owner        4096 Feb  6 18:39 .
drwxr-xr-x    7 root     root         4096 Feb  6 18:39 ..
$ strace -e mkdir /bin/mkdir aap
mkdir("aap", 0777)                      = 0


Problem was originally found on 2.6.10 and looks like a server problem
because of the following and because 2.4.28 as server worked.  I have
tracked it down in 2.6.10 to the following client side call tree:

sys_mkdir() ->
vfs_mkdir() ->
may_create() ->
permission(MAY_WRITE | MAY_EXEC) ->
nfs_permission(MAY_WRITE | MAY_EXEC) ->
nfs_do_access(MAY_WRITE | MAY_EXEC):
	nfs_access_get_cached(): -ENOENT
	nfs3_proc_access(MAY_EXEC | MAY_WRITE | MAY_READ):
		arg.access = 0x1f (everything except NFS3_ACCESS_EXECUTE)
		RPC returns 0
		res.access = 0x3  (NFS3_ACCESS_READ|NFS3_ACCESS_LOOKUP)
		modify the cached mask: set it to 0x5 (MAY_EXEC | MAY_READ)
	if ((0x1f & 0x5) == 0x3)
		return 0;
	-EACCES

I think the server forgot to mention NFS3_ACCESS_MODIFY or
NFS3_ACCESS_EXTEND for the directory (I'm too lazy to look it up in
the RFCs right now).

-- 
Frank


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
