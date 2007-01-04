From: Stephan Henningsen <sth@amplex.dk>
Subject: Trouble accessing NFS mountpoint as user
Date: Thu, 04 Jan 2007 09:23:06 +0100
Message-ID: <459CB96A.1060806@amplex.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H2Nsq-00017l-P3
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 00:23:33 -0800
Received: from [62.242.67.89] (helo=server.amplex.dk)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1H2Nsr-0004NN-Sh
	for nfs@lists.sourceforge.net; Thu, 04 Jan 2007 00:23:34 -0800
To: nfs@lists.sourceforge.net
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

Hi,

I'm exporting a directory on my server.  Access to the export is restricted 
  to local users by permissions.

When I mount it as user (or root) on my client, only root has access to the 
mountpoint.  The client user's permissions match those of the export on the 
server.

Will someone on this mailing list please be so kind and try to help me?
I've been asking for help on IRC and studing HOWTOs for a few days, but 
still without success.  I suspect this is not a trivial problem.  Please 
read the info supplied below.  I'll of course hand out more if necessary.
Thanks =)



The server (colossus.sputnik.lan = 10.0.0.1) is configured as follows:

stephan@colossus:~$ grep colossus-files /etc/group
colossus-files:x:200:stephan

stephan@colossus:~$ id
uid=1000(stephan) gid=1000(stephan) 
groups=4(adm),20(dialout),24(cdrom),25(floppy),29(audio),30(dip),44(video),46(plugdev),100(users),109(lpadmin),110(scanner),111(admin),114(svn),200(colossus-files),1000(stephan)

stephan@colossus:~$ ls -ld /var/files/
drwxrwx--- 8 root colossus-files 4096 Jan  3 21:58 /var/files//

stephan@colossus:~$ ls -ldn /var/files/
drwxrwx--- 8 0 200 4096 Jan  3 21:58 /var/files//

stephan@colossus:~$ touch /var/files/SUCCESS

stephan@colossus:~$ grep /var/files /etc/exports
/var/files *.sputnik.lan(rw,sync,no_root_squash,no_all_squash,no_subtree_check)

stephan@colossus:~$ rpcinfo -p localhost
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  32805  status
     100024    1   tcp  46015  status
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100003    4   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100003    3   tcp   2049  nfs
     100003    4   tcp   2049  nfs
     100021    1   udp  32807  nlockmgr
     100021    3   udp  32807  nlockmgr
     100021    4   udp  32807  nlockmgr
     100021    1   tcp  47227  nlockmgr
     100021    3   tcp  47227  nlockmgr
     100021    4   tcp  47227  nlockmgr
     100005    1   udp    820  mountd
     100005    1   tcp    823  mountd
     100005    2   udp    820  mountd
     100005    2   tcp    823  mountd
     100005    3   udp    820  mountd
     100005    3   tcp    823  mountd

stephan@colossus:~$ exportfs -v | grep /var/files
/var/files 
*.sputnik.lan(rw,wdelay,no_root_squash,no_subtree_check,anonuid=65534,anongid=65534)

stephan@colossus:~$ cat /etc/hosts.allow
portmap:        10.0.0.3
lockd:          10.0.0.3
mountd:         10.0.0.3
rquotad:        10.0.0.3
statd:          10.0.0.3

stephan@colossus:~$ cat /etc/hosts.deny
portmap: ALL
lockd:   ALL
mountd:  ALL
rquotad: ALL
statd:   ALL

stephan@colossus:~$ uname -a
Linux colossus 2.6.17-10-server #2 SMP Fri Oct 13 18:47:26 UTC 2006 i686 
GNU/Linux

stephan@colossus:~$ nfsstat --version
nfsstat: 1.0.9





The client (tetris.sputnik.lan = 10.0.0.3) is configured as follows:

stephan@tetris:~$ grep colossus-files /etc/group
colossus-files:x:200:stephan

stephan@tetris:~$ id
uid=1000(stephan) gid=1000(stephan) 
groups=4(adm),20(dialout),21(fax),22(voice),24(cdrom),25(floppy),26(tape),27(sudo),29(audio),30(dip),44(video),50(staff),60(games),100(users),103(thinkpad),109(camera),110(nvram),111(admin),200(colossus-files),1000(stephan)

stephan@tetris:~$ grep /var/files /etc/fstab
colossus.sputnik.lan:/var/files /home/stephan/mnt/f nfs 
rw,rsize=8192,wsize=8192,hard,intr,timeo=7 0 0

stephan@tetris:~$ ls -ld /home/stephan/mnt/f
drwx------ 2 stephan stephan 4.0K Jan  2 20:29 /home/stephan/mnt/f/

stephan@tetris:~$ mount /home/stephan/mnt/f

stephan@tetris:~$ ls -ld /home/stephan/mnt/f
drwxrwx--- 8 root colossus-files 4.0K Jan  4 04:58 /home/stephan/mnt/f/

Mounted exactly as expected, but now trouble appears:

stephan@tetris:~$ ls /home/stephan/mnt/f
ls: /home/stephan/mnt/f: Permission denied

stephan@tetris:~$ sudo ls /home/stephan/mnt/f
-rw-r--r--   1 stephan stephan    0 Jan  4  2007 SUCCESS

Testing a local directory with same permissions:

stephan@tetris:~$ sudo install -d /home/stephan/mnt/accesstest -o root -g 
colossus-files -m 770

stephan@tetris:~$ ls -ld /home/stephan/mnt/accesstest/
drwxrwx--- 2 root colossus-files 4.0K Jan  4 09:11 
/home/stephan/mnt/accesstest//

stephan@tetris:~$ ls  /home/stephan/mnt/accesstest/SUCCESS
-rw------- 1 stephan stephan 0 Jan  4 09:13 
/home/stephan/mnt/accesstest/SUCCESS

stephan@tetris:~$ rpcinfo -p colossus
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp  32805  status
     100024    1   tcp  46015  status
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100003    4   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100003    3   tcp   2049  nfs
     100003    4   tcp   2049  nfs
     100021    1   udp  32807  nlockmgr
     100021    3   udp  32807  nlockmgr
     100021    4   udp  32807  nlockmgr
     100021    1   tcp  47227  nlockmgr
     100021    3   tcp  47227  nlockmgr
     100021    4   tcp  47227  nlockmgr
     100005    1   udp    820  mountd
     100005    1   tcp    823  mountd
     100005    2   udp    820  mountd
     100005    2   tcp    823  mountd
     100005    3   udp    820  mountd
     100005    3   tcp    823  mountd

stephan@tetris:~$ uname -a
Linux tetris 2.6.17.7 #6 Sat Sep 23 12:21:38 CEST 2006 i686 GNU/Linux

stephan@tetris:~$ nfsstat --version
nfsstat: 1.0.10

-- 
Stephan Henningsen

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
