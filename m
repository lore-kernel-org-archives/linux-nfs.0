From: Steven Timm <timm@fnal.gov>
Subject: Caching problem
Date: Fri, 28 Apr 2006 16:40:15 -0500 (CDT)
Message-ID: <Pine.LNX.4.62.0604281630230.6585@snowball.fnal.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FZbfu-0000UH-Go
	for nfs@lists.sourceforge.net; Fri, 28 Apr 2006 15:42:58 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FZbfu-00025a-If
	for nfs@lists.sourceforge.net; Fri, 28 Apr 2006 15:42:58 -0700
Received: from mailgw2.fnal.gov ([131.225.111.12])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FZbft-0007kW-Jx
	for nfs@lists.sourceforge.net; Fri, 28 Apr 2006 15:42:58 -0700
Received: from mailav1.fnal.gov (mailav1.fnal.gov [131.225.111.18])
 by mailgw2.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with SMTP id <0IYG0050YC4JGD@mailgw2.fnal.gov> for nfs@lists.sourceforge.net;
 Fri, 28 Apr 2006 16:40:15 -0500 (CDT)
Received: from mailgw1.fnal.gov ([131.225.111.11])
 by mailav1.fnal.gov (SAVSMTP 3.1.7.47) with SMTP id M2006042816401516784 for
 <nfs@lists.sourceforge.net>; Fri, 28 Apr 2006 16:40:15 -0500
Received: from conversion-daemon.mailgw1.fnal.gov by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 id <0IYG00201BSZRG@mailgw1.fnal.gov> (original mail from timm@fnal.gov)
 for nfs@lists.sourceforge.net; Fri, 28 Apr 2006 16:40:15 -0500 (CDT)
Received: from snowball.fnal.gov (snowball.fnal.gov [131.225.81.94])
 by mailgw1.fnal.gov
 (iPlanet Messaging Server 5.2 HotFix 2.06 (built Mar 28 2005))
 with ESMTPS id <0IYG003PZC73BA@mailgw1.fnal.gov> for
 nfs@lists.sourceforge.net; Fri, 28 Apr 2006 16:40:15 -0500 (CDT)
Received: from snowball.fnal.gov (localhost.localdomain [127.0.0.1])
	by snowball.fnal.gov (8.13.1/8.13.1) with ESMTP id k3SLeFpq008858	for
 <nfs@lists.sourceforge.net>; Fri, 28 Apr 2006 16:40:15 -0500
Received: from localhost (timm@localhost)
	by snowball.fnal.gov (8.13.1/8.13.1/Submit) with ESMTP id k3SLeFgb008855	for
 <nfs@lists.sourceforge.net>; Fri, 28 Apr 2006 16:40:15 -0500
To: nfs@lists.sourceforge.net
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


I have a nfs caching problem between a server and a client.
Here's a simple shell script which can reproduce it when the system
is in this state, which fortunately is not all the time.

[timm@fngp-osg ~/test]$ cat ../test4.sh
#!/bin/bash
i=0
while true
do
         if [ ! -s a ]
         then
                 cp /home/timm/a ./a
         fi
         ln a b
         cat b
         rm b
         i=`expr $i + 1`
         echo $i
done


[timm@fngp-osg ~/test]$ pwd
/home/timm/test


fngp-osg is the client.
fnpcsrv1 is the server.
[root@fnpcsrv1 test]# grep fngp-osg /var/lib/nfs/xtab
/export/lsi_home        fngp-osg.fnal.gov(rw,sync,wdelay,hide,nocrossmnt,insecure,root_squash,no_all_squash,no_subtree_check,insecure_locks,acl,mapping=identity,anonuid=-2,anongid=-2)


fnpcsrv1:/export/lsi_home/timm on /home/timm type nfs 
(rw,noatime,nodiratime,hard,tcp,timeo=600,retrans=8,intr,rsize=32768,wsize=32768,0,0,addr=131.225.167.44)

Part of the output from the script is as follows:

160
ln: `b': File exists
one
two
three
four
five
six
seven
eight
nine
ten

When it is in the wierd state:
On the server, file "b" does not exist in /home/timm/test
[root@fnpcsrv1 test]# ls -l /home/timm/test
total 4
-rw-r--r--    1 timm     oss            49 Mar  3 10:03 a
[root@fnpcsrv1 test]#

On the client
[timm@fngp-osg ~/test]$ ls -l /home/timm/test
total 4
-rw-r--r--    1 timm     oss            49 Mar  3 10:03 a
[timm@fngp-osg ~/test]$                           \
timm@fngp-osg ~/test]$ ls -l /home/timm/test/b
-rw-r--r--    1 timm     oss            49 Mar  3 10:03 /home/timm/test/b
[timm@fngp-osg ~/test]$  [timm@fngp-osg ~/test]$ cat /home/timm/test/b
one
two
three
four
five
six
seven
eight
nine
ten
[timm@fngp-osg ~/test]$ rm b
rm: cannot remove `b': No such file or directory

If the file is recreated on the server, the script goes
on its merry way for awhilen, then gets into the loop.

Every once in a while either the ln or the rm process of the script
hangs in state "D"

Neither client or server are particuarly busy right now.
client load is 2, server load is 0.16.

Any idea what might be happening here?

These are both kernels more or less as shipped with red hat enterprise 3
update 5, 2.4.21-37.  the server kernel has XFS extensions compiled in
and the server file system is XFS.


Any idea what might be going on here?  Anyone ever seen this before?

You might ask--the above script is a stupid thing to be doing, why do it?
There's a third party app that is using this hard link across nfs in
place of file locking for some of the stuff it is doing.  That's where
it comes from.

Sometimes this is accompanied by errors on the server

Apr 28 16:39:08 fnpcsrv1 kernel: rpc-srv/tcp: nfsd: sent only -107 bytes 
of 132 - shutting down socket
Apr 28 16:39:10 fnpcsrv1 kernel: rpc-srv/tcp: nfsd: sent only -107 bytes 
of 132 - shutting down socket
Apr 28 16:39:10 fnpcsrv1 kernel: rpc-srv/tcp: nfsd: sent only -107 bytes 
of 264 - shutting down socket

but the above errors also happen even when I'm not running this test 
script.

Any help is appreciated.

Steve Timm



-- 
------------------------------------------------------------------
Steven C. Timm, Ph.D  (630) 840-8525  timm@fnal.gov  http://home.fnal.gov/~timm/
Fermilab Computing Div/Core Support Services Dept./Scientific Computing Section
Assistant Group Leader, Farms and Clustered Systems Group
Lead of Computing Farms Team


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
