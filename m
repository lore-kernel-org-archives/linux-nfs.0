From: Bodo Eggert <7eggert@gmx.de>
Subject: Inconsistent ACL beahaviour with nfs vs. local
Date: Fri, 15 Jun 2007 14:55:49 +0200 (CEST)
Message-ID: <Pine.LNX.4.58.0706142103460.5998@be1.lrz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HzBM5-0001HY-Jl
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 05:56:45 -0700
Received: from moutng.kundenserver.de ([212.227.126.188])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HzBM7-0004qK-Cn
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 05:56:49 -0700
Received: from be1.lrz ([192.168.7.201])
	by be10.7eggert.dyndns.org with esmtp (Exim 4.54) id 1HzBLC-0002G5-5R
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 14:55:50 +0200
Received: from 7eggert (helo=localhost) by be1.lrz with local-esmtp (Exim 4.22)
	id 1HzBLB-0000sN-Mg
	for nfs@lists.sourceforge.net; Fri, 15 Jun 2007 14:55:49 +0200
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Please CC me on reply.

I'd like to set up a public directory tree to let one user (me) 
administrate everything, and all users to r-x all files. I set
up these ACL:

# file: .
# owner: root
# group: root
user::rwx
group::rwx
other::r-x
default:user::rwx
default:user:7eggert:rwx
default:group::rwx
default:mask::rwx
default:other::r-x

If I'm working from the local machine, the fs behaves as intended, but if 
I'm working from NFS, the umask group bits will clobber the mask bits:

root@server: mkdir from-local
root@client: mkdir from-nfs (mounted no_squash, umask=022)

# file: from-local
# owner: root
# group: root
user::rwx
user:7eggert:rwx
group::rwx
mask::rwx
other::r-x
default:user::rwx
default:user:7eggert:rwx
default:group::rwx
default:mask::rwx
default:other::r-x

# file: from-nfs
# owner: root
# group: root
user::rwx
user:7eggert:rwx                #effective:r-x
group::rwx                      #effective:r-x
mask::r-x
other::r-x
default:user::rwx
default:user:7eggert:rwx
default:group::rwx
default:mask::rwx
default:other::r-x


The same undesired behaviour has been acknowledged as a bug in Solaris:
http://groups.google.com/group/comp.unix.solaris/browse_thread/thread/
ced50ad4a93cc9f7/73b1c841180d4010?lnk=st&q=acl+default+mask&rnum=16&hl=en


Used versions:
Server kernel is 2.6.16 (cannot be upgraded due to external module)
Client kernel is 2.6.21
Filesystem is reiserfs3
NFS version is now 4, I upgraded from v2 while trying to resolve this problem.
util-linux-2.11z-125
libevent-0.7.tar.gz
libgssapi-0.11.tar.gz
libnfsidmap-0.19.tar.gz
librpcsecgss-0.14.tar.gz
nfs-utils-1.1.0.tar.gz
e2fsprogs-1.39.tar.gz
acl-2.2.15-23 (this would not affect the kernel nfs daemon, would it?)
libacl-2.2.15-23
libacl-devel-2.2.15-23


exportfs -v: (trimmed)
/export/data    
192.168.x.xxx(rw,async,wdelay,crossmnt,no_root_squash,no_subtree_check,mountpoint)
/export         
<world>(rw,wdelay,crossmnt,root_squash,all_squash,no_subtree_check,fsid=0)


Please CC me on reply.
-- 
Top 100 things you don't want the sysadmin to say:
81. The drive ate the tape but that's OK, I brought my screwdriver.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
