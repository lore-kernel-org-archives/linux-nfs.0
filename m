From: "matteo.debiaggi" <matteo.debiaggi@charta.it>
Subject: Lock problem.
Date: Thu, 11 Oct 2007 10:56:32 +0200
Message-ID: <470DE540.1090908@charta.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IftqV-0001nB-Bw
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 01:56:43 -0700
Received: from [213.209.214.162] (helo=charta.it)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IftqV-0006xp-Jm
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 01:56:48 -0700
Received: from [10.100.11.235] (lproxy.charta.it [192.168.1.100])
	(authenticated bits=0)
	by charta.it (8.12.11/8.12.11) with ESMTP id l9B8uWvw011241
	for <nfs@lists.sourceforge.net>; Thu, 11 Oct 2007 10:56:32 +0200 (MEST)
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

Hi at all,
Situation :

I have a linux client :
debian,  kernel  2.6.16
64bit
nfs-common_1%3a1.0.6-3.1_amd64.deb

rpcinfo -p localhosts stats(about nfs..)
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100021    1   udp  34865  nlockmgr
    100021    3   udp  34865  nlockmgr
    100021    4   udp  34865  nlockmgr
    100021    1   tcp  40293  nlockmgr
    100021    3   tcp  40293  nlockmgr
    100021    4   tcp  40293  nlockmgr

And a soalris 8 with all possible patches( or better, all patches i 
found..) relative to nfs.
32bit

rpcinfo -p localhost stats(about nfs..)
 program vers proto   port  service
    100011    1   udp  32773  rquotad
    100001    2   udp  32777  rstatd
    100001    3   udp  32777  rstatd
    100001    4   udp  32777  rstatd
    100021    1   udp   4045  nlockmgr
    100021    2   udp   4045  nlockmgr
    100021    3   udp   4045  nlockmgr
    100021    4   udp   4045  nlockmgr
    100021    1   tcp   4045  nlockmgr
    100021    2   tcp   4045  nlockmgr
    100021    3   tcp   4045  nlockmgr
    100021    4   tcp   4045  nlockmgr
    100005    1   udp  36355  mountd
    100005    2   udp  36355  mountd
    100005    3   udp  36355  mountd
    100005    1   tcp  49762  mountd
    100005    2   tcp  49762  mountd
    100005    3   tcp  49762  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100227    2   udp   2049  nfs_acl
    100227    3   udp   2049  nfs_acl
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100227    2   tcp   2049  nfs_acl
    100227    3   tcp   2049  nfs_acl

Client wants work with files located in a dir shared with  parameters:
share   -F   nfs     -o rw,root=nb,anon=505 /dir
Client mounts dir  in this way :
....type nfs (rw,noexec,nosuid,nodev,sync,actimeo=0,noac,addr=....,user=...)

In the shared dir  there are concurrent processes writing their own 
content on the same file.
They make files as root but with ugo 666.

In the client side  another process has a loop looking for mentioned 
file. Whenever it finds file, it tryes to read it.

Problem :
 Some times, not every times ,we face a strange lock where reader waits 
more or less for the same time( about 30sec,uhm..) lock gets acquired, 
at the end it did it.

Here's simplyfied code:

WRITER:

for (;;) {
  fd = open(file, O_WRONLY|O_APPEND|O_CREAT, 0666);
  lockf(fd, F_LOCK, 0);
  write(fd, line, LINE_SIZE);
  lockf(fd, F_ULOCK, 0);
  close(fd);

  usleep(WR_PAUSE);
}


READER:

for (;;) {
  while(access(file, F_OK))
    usleep(RD_PAUSE);

  fd = open(file, O_RDWR);
  lockf(fd, F_LOCK, 0);
  unlink(file);
  lockf(fd, F_ULOCK, 0);
  lockf(fd, F_LOCK, 0); /* incriminated lock !!! */

  while (read(fd, line, LINE_SIZE) == LINE_SIZE)
    ++line_numb;

  close(fd);
}


Any help would be appreciated.
Thanks in advance.
Matteo.







-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
