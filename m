From: foo@posern.org
Subject: nfs v3: chown not permitted
Date: Mon, 22 Mar 2004 15:39:22 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040322143922.GA2452@posern.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5Qar-0001LP-1U
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 06:39:57 -0800
Received: from mailout05.sul.t-online.com ([194.25.134.82])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5Qap-0006kJ-Ab
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 06:39:55 -0800
To: nfs@lists.sourceforge.net
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


Hi.

I hope its not a total stupid question...

...but I tried... read man-pages, searched on google...

So here is the situation:

nfs-server: FILESERVER = 10.10.10.3 = linux debian stable + security + backports


root@FILESERVER:~# uname -a
Linux FILESERVER 2.6.4 #1 Mon Mar 22 13:35:27 CET 2004 i686 unknown


root@FILESERVER:~# dpkg -l|grep nfs
ii  nfs-common     1.0-2woody1    NFS support files common to client and serve
ii  nfs-kernel-ser 1.0-2woody1    Kernel NFS server support


root@FILESERVER:~# cat /usr/src/linux/.config|grep -i nfs
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V4 is not set
# CONFIG_NFSD_TCP is not set


root@FILESERVER:~# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1026  nlockmgr
    100021    3   udp   1026  nlockmgr
    100021    4   udp   1026  nlockmgr
    100005    1   udp   4002  mountd
    100005    1   tcp   4002  mountd
    100005    2   udp   4002  mountd
    100005    2   tcp   4002  mountd
    100005    3   udp   4002  mountd
    100005    3   tcp   4002  mountd


root@FILESERVER:~# cat /etc/exports
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# rw = read AND write access (instead of ro)
# sync = new default (instead of async) (without it always gives a warn-message)
# root_squash = while mounting the user ID of 'root' on the nfs client
#               is replaced with ID of 'nobody' on the nfs SERVER
# nosuid = prevents files with suid bits set on the nfs SERVER from being executed
# noexec = disables any file execution at all
/mnt/data 10.10.10.10(rw,sync,root_squash)



+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



nfs-client: jolie = 10.10.10.10 = linux debian unstable installation


jolie:/mnt# uname -a
Linux jolie 2.6.3 #3 Thu Mar 4 01:18:21 CET 2004 i686 GNU/Linux


jolie:/mnt# dpkg -l|grep nfs
ii  nfs-common     1.0.6-1        NFS support files common to client and serve
ii  nfs-kernel-ser 1.0.6-1        Kernel NFS server support


jolie:/mnt# cat /usr/src/linux/.config|grep -i nfs
CONFIG_NFS_FS=m
CONFIG_NFS_V3=y
# CONFIG_NFS_V4 is not set
# CONFIG_NFS_DIRECTIO is not set
CONFIG_NFSD=m
CONFIG_NFSD_V3=y
# CONFIG_NFSD_V4 is not set
# CONFIG_NFSD_TCP is not set


jolie:/mnt# rpcinfo -p
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp  32770  nlockmgr
    100021    3   udp  32770  nlockmgr
    100021    4   udp  32770  nlockmgr
    100005    1   udp   4002  mountd
    100005    1   tcp   4002  mountd
    100005    2   udp   4002  mountd
    100005    2   tcp   4002  mountd
    100005    3   udp   4002  mountd
    100005    3   tcp   4002  mountd
    100024    1   udp    877  status
    100024    1   tcp    880  status


jolie:/mnt# cat /etc/fstab |grep nfs
10.10.10.3:/mnt/data   /mnt/lauschers-data nfs defaults,noauto,user,rsize=8192,wsize=8192        0  0


me@jolie:/mnt$ ls -l -d /mnt/lauschers-data/
drwxr-x---   18 me       mine         4096 Mar 22 12:26 /mnt/lauschers-data/


me@jolie:/mnt$ mount -v /mnt/lauschers-data/
10.10.10.3:/mnt/data on /mnt/lauschers-data type nfs (rw,noexec,nosuid,nodev,rsize=8192,wsize=8192,addr=10.10.10.3,user=me)
me@jolie:/mnt$


me@jolie:/mnt$ ls -l -d /mnt/lauschers-data/
drwxr-x---   18 me       mine         4096 Mar 22 12:26 /mnt/lauschers-data/


me@jolie:/mnt$ ls -l /mnt/lauschers-data/|grep uni
drwxr-xr-x    9 me       mine         4096 Dec 24 00:54 uni


me@jolie:/mnt$ groups
mine root adm disk lp dialout cdrom floppy audio www-data src video prg data mp3 maildata newmp3 wg users lpadmin


me@jolie:/mnt$ chown me:users /mnt/lauschers-data/uni/
chown: changing ownership of `/mnt/lauschers-data/uni/': Operation not permitted


And last but not least I also checked:

jolie:/etc# diff /etc/group /etc/group.FILESERVER
jolie:/etc#
jolie:/etc# diff /etc/passwd /etc/passwd.FILESERVER
jolie:/etc#


WHY???????

--> Or is it that a normal user is not allowed in general to chown over nfs???

--> Or would nfs4 be a solution???

Any help is very appreciated!

By the way: In which state is nfs v4? - Its already more or less usable? <<< because from time to time I am looking at www.nfsv4.org, but there is sadly nothing written about the state of development of nfsv4...


Greetings

Knuth Posern.


P.S.: I hope I forgot no information... ;-)



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
