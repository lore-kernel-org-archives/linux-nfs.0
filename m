From: Shunichi Sagawa <s-sagawa@jp.fujitsu.com>
Subject: Permission information on the directory is output with ?
Date: Thu, 24 May 2007 17:59:34 +0900
Message-ID: <20070524175934.17a59a57.s-sagawa@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hr9Au-00058J-6L
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 02:00:00 -0700
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hr9Av-0001Vu-Ac
	for nfs@lists.sourceforge.net; Thu, 24 May 2007 02:00:02 -0700
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id
	l4O8xq68004243
	for <nfs@lists.sourceforge.net> (envelope-from s-sagawa@jp.fujitsu.com);
	Thu, 24 May 2007 17:59:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 396BE240063
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 17:59:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0083A2DC054
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 17:59:52 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6 [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id CD609161C00A
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 17:59:51 +0900 (JST)
Received: from fjm504.ms.jp.fujitsu.com (fjm504.ms.jp.fujitsu.com
	[10.56.99.80])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 257E3161C027
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 17:59:49 +0900 (JST)
Received: from fjmscan501.ms.jp.fujitsu.com (fjmscan501.ms.jp.fujitsu.com
	[10.56.99.141])by fjm504.ms.jp.fujitsu.com with ESMTP id
	l4O8xYQ3008346
	for <nfs@lists.sourceforge.net>; Thu, 24 May 2007 17:59:34 +0900
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

Hello, all 

I face the problem that the directory's permission information on
NFS server cannot be correctly acquired.

  # ls -l /po/spool/postfix
  total 52
  drwx------  18 postfix root     4096 May 22 00:45 active
  drwx------   2 postfix root     4096 Feb 11  2005 bounce
  drwx------   2 postfix root     4096 Feb 11  2005 corrupt
  drwx------   5 postfix root     4096 May 22 02:21 defer
  drwx------   5 postfix root     4096 May 22 02:21 deferred
  drwx------   2 postfix root     4096 Feb 11  2005 flush
  -rw-r--r--   1 root    root        0 May 24  2007 hogehoge
  drwx------   2 postfix root     4096 Feb 11  2005 hold
  ?---------   ? ?       ?           ?            ? incoming    <== here
  drwx-wx---   2 postfix postdrop 4096 May 23  2007 maildrop
  drwxr-xr-x   2 root    root     4096 May 21 14:35 pid
  drwx------   2 postfix root     4096 May 21 14:35 private
  drwx--x---   2 postfix postdrop 4096 May 21 14:35 public
  drwx------   2 postfix root     4096 Feb 11  2005 saved
  drwx------   2 postfix root     4096 Feb 11  2005 trace
  #

[System configuration]

        nfs-server(RHEL4UP3)
       +- x86 machine ----+
       |                  |
       +------------------+             nfs-client(RHEL4UP1)
          |                            +-x86 machine -----------------------------------------------+
          |                    nfs     |                                                            |
       +----disk----------+  <-------> |         mount /po       (option noac)                      |
       | /vol/vol0/jpmail |            |                 |-spool                                    |
       |                  |            |                 |  |-postfix                               |
       |                  |            |                 |  |  |-active                             |
       |                  |            |                 |  |  :                                    |
       |                  |            |                 |  |  |-incoming(ls -l /po/spool/postfix ?)|
       |                  |            |                 |  |  |-maildrop(ls -l /po/spool/postfix ?)|
       |                  |            |                 |  |  :                                    |
       +------------------+            |                 |-vmbox                                    |
                                       +------------------------------------------------------------+


[Reproduction procedure]
If the following operation is done, the output result becomes abnormal. 

1. For giving high load, please execute tarloop.sh.
   This script is accessed to a local disk.

  # cat tarloop.sh
  #!/bin/sh
  count=1
  while :
  do
       time=`date`
       echo "$time count=$count"
       tar xfz ./dummydir.tgz
       du -a dummydir
       rm -rf dummydir
       count=$(($count+1))
  done
  # ls -l dummydir.tgz
  -rw-r--r--  1 root root 965148975 May 22 11:59 dummydir.tgz
  #

2. For NFS access, please execute postfix like this.

  # telnet localhost 25
  Trying 127.0.0.1...
  Connected to localhost.localdomain (127.0.0.1).
  Escape character is '^]'.
  220 hazard.soft.fujitsu.com ESMTP Postfix
  helo soft.fujitsu.com  -------------------------> (1)
  250 hazard.soft.fujitsu.com
  mail from: s-sagawa@jp.fujitsu.com -------------> (2)
  250 Ok
  rcpt to: s-sagawa@jp.fujitsu.com ---------------> (3)
  250 Ok
  :
  (1) - (3) repeat.

  ###################################################################
  - The incidence of this problem is about 10%.
  - When the same procedure is executed after umount/mount is operated,
    it is easy to be generated.
  ###################################################################

  [OK pattern]
  helo soft.fujitsu.com  -------------------------> (1)
  250 hazard.soft.fujitsu.com
  mail from: s-sagawa@jp.fujitsu.com -------------> (2)
  250 Ok
  rcpt to: s-sagawa@jp.fujitsu.com ---------------> (3)
  250 Ok
  [NG pattern]
  helo soft.fujitsu.com  -------------------------> (1)
  250 hazard.soft.fujitsu.com
  mail from: s-sagawa@jp.fujitsu.com -------------> (2)
  250 Ok
  rcpt to: s-sagawa@jp.fujitsu.com ---------------> (3)


  When "250 OK" is not output, this problem has been reproduced.

  # df
  Filesystem           1K-blocks      Used Available Use% Mounted on
  /dev/sda8             19931708  13363664   5555552  71% /
  none                    517336         0    517336   0% /dev/shm
  /dev/sdb1             70557052  43613868  23359088  66% /work
  rhas4up3-part2:/vol/vol0/jpmail
                         8143616   4978528   2751392  65% /po
  #
  # ls -i /po/spool/postfix/
  339662 active   339665 defer     339719 hogehoge  339670 maildrop  339693 public
  339663 bounce   339666 deferred  339668 hold      339671 pid       339699 saved
  339664 corrupt  339667 flush          0 incoming  339673 private   339700 trace
  #
  # cd /po/spool/postfix/incoming
  -bash: cd: /po/spool/postfix/incoming: No such file or directory
  #

What is wrong? And is there any patch?


Regards,
Sagawa

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
