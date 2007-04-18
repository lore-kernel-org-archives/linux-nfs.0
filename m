From: "Willem de Groot" <willem@byte.nl>
Subject: Inconsistencies between NFS clients
Date: Wed, 18 Apr 2007 11:51:15 +0200
Message-ID: <3aa9dfd20704180251u2fd0450jcc8c4f674bb041a4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1He6om-0008Rt-4p
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 02:51:17 -0700
Received: from nz-out-0506.google.com ([64.233.162.226])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1He6om-0000Yg-GH
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 02:51:18 -0700
Received: by nz-out-0506.google.com with SMTP id i11so151206nzi
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 02:51:15 -0700 (PDT)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi!

Running Debian Sarge, nfs-kernel-server 1.0.6-3.1. Fileserver has ext3 fs.
About 7 clients that mount a share using this fstab line:
nfs-users:/srv/home/users       /home/users         nfs
rw,bg,nosuid,hard,intr,rsize=8192,wsize=8192,nfsvers=3,posix 0 0
Client kernels: 2.6.17.13

But, after one client has deleted a particular file, the update is
known on all but two clients:

for i in `webboxes`; do echo -n "$i: "; ssh $i ls -la /particular/file; done
web1: -rw-r--r--  1 eigeoftp wwwuser 2876 2006-09-04 11:30 /particular/file
web2: -rw-r--r--  1 eigeoftp wwwuser 2876 2006-09-04 11:30 /particular/file
web3: ls: /particular/file: No such file or directory
web4: ls: /particular/file: No such file or directory
webs1: ls: /particular/file: No such file or directory
webs2: ls: /particular/file: No such file or directory
office2: ls: /particular/file: No such file or directory

The mtime of the parent directory also differs between web1/2 and the rest.

Over the past couple months, this has happened about 3 times (for
different files). Remounting the share on the client has resolved the
problem but apparently not in the long run.

Enabling NFS debug @ web1 and issuing "ls -la /particular/file" yields:

Apr 18 11:40:45 web1 kernel: NFS: nfs_update_inode(0:10/4866049 ct=1 info=0x6)
Apr 18 11:40:45 web1 kernel: NFS: permission(0:10/4866049), mask=0x1, res=0
Apr 18 11:40:45 web1 kernel: NFS: nfs_update_inode(0:10/7914106 ct=1 info=0x6)
Apr 18 11:40:45 web1 kernel: NFS: permission(0:10/7914106), mask=0x1, res=0
Apr 18 11:40:45 web1 kernel: NFS: nfs_update_inode(0:10/7914107 ct=1 info=0x6)
Apr 18 11:40:45 web1 kernel: NFS: permission(0:10/7914107), mask=0x1, res=0
Apr 18 11:40:45 web1 kernel: NFS: nfs_update_inode(0:10/7914482 ct=1 info=0x6)
Apr 18 11:40:45 web1 kernel: NFS: permission(0:10/7914482), mask=0x1, res=0
Apr 18 11:40:45 web1 kernel: NFS: nfs_update_inode(0:10/7914486 ct=1 info=0x6)
Apr 18 11:40:45 web1 kernel: NFS: permission(0:10/7914486), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: nfs_update_inode(0:10/35553320 ct=1 info=0x6)
Apr 18 11:40:46 web1 kernel: NFS: dentry_delete(particular/file, 8)
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/4866049), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914106), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914107), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914482), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914486), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: dentry_delete(particular/file, 8)
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/4866049), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914106), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914107), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914482), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: permission(0:10/7914486), mask=0x1, res=0
Apr 18 11:40:46 web1 kernel: NFS: dentry_delete(particular/file, 8)

Does this give a clue about what's going wrong? What other things can
I do to debug the problem? I have isolated one box that has gone awry
for further examination.

Thanks!
Willem

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
