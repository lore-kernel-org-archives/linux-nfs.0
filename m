From: Chung-Jung Tsai <tsai@protein3d.ncifcrf.gov>
Subject: a NFS problem
Date: Wed, 9 Oct 2002 16:38:41 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200210092038.QAA47299@protein3d.ncifcrf.gov>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from protein3d.ncifcrf.gov ([129.43.6.58])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zNk6-0002F4-00
	for <nfs@lists.sourceforge.net>; Wed, 09 Oct 2002 13:47:42 -0700
Received: (from tsai@localhost)
	by protein3d.ncifcrf.gov (SGI-8.9.3/8.9.3) id QAA47299
	for nfs@lists.sourceforge.net; Wed, 9 Oct 2002 16:38:41 -0400 (EDT)
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Hi,

We will appreciate if anyone can suggest a solution to our NFS problem.
We were running a linux cluster with redhat 7.3.  

The NFS problem is:

Files written by a f90 program running at master node were not updated 
for the other nodes to see their content correctly. It seems like a sync 
problem.

The NFS was mounted with the options:
master:/home    /home   nfs    rsize=8192,wsize=8192,actimeo=0,noac,intr 0 0

some output from nfsstat:

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
1340341394   0          0          0          0       

Server nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 1300536271  0% 13116771  0% 37991   0% 1579    0% 32      0% 
read       write      create     mkdir      symlink    mknod      
13134415  0% 13250369  0% 1821    0% 12      0% 22      0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
1111    0% 0       0% 291     0% 140     0% 306     0% 0       0% 
fsstat     fsinfo     pathconf   commit     
20971   0% 20971   0% 0       0% 218321  0% 

Client rpc stats:
calls      retrans    authrefrsh
9509       0          0       

Client nfs v3:
null       getattr    setattr    lookup     access     readlink   
0       0% 25      0% 0       0% 2725   28% 2770   29% 2       0% 
read       write      create     mkdir      symlink    mknod      
0       0% 0       0% 0       0% 0       0% 0       0% 0       0% 
remove     rmdir      rename     link       readdir    readdirplus
0       0% 0       0% 0       0% 0       0% 159     1% 0       0% 
fsstat     fsinfo     pathconf   commit     
1914   20% 1914   20% 0       0% 0       0% 


				C. J. Tsai



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
