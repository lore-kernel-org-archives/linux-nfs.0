From: Jonas Lindemann <jonas.lindemann@byggmek.lth.se>
Subject: Strange behavior of executable bit
Date: Wed, 26 May 2004 10:05:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <40B44FE7.6010601@byggmek.lth.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BStQQ-0000AW-CN
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 01:06:10 -0700
Received: from av5-2-sn3.vrr.skanova.net ([81.228.9.114])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BStQN-0005li-Db
	for nfs@lists.sourceforge.net; Wed, 26 May 2004 01:06:07 -0700
Received: from smtp1-2-sn3.vrr.skanova.net (smtp1-2-sn3.vrr.skanova.net [81.228.9.178])
	by av5-2-sn3.vrr.skanova.net (Postfix) with ESMTP id 85DA537E42
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 10:06:01 +0200 (CEST)
Received: from byggmek.lth.se (h5n2fls309o1101.telia.com [81.226.193.5])
	by smtp1-2-sn3.vrr.skanova.net (Postfix) with ESMTP id 44F733800F
	for <nfs@lists.sourceforge.net>; Wed, 26 May 2004 10:06:01 +0200 (CEST)
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

Hi!

We have an file server runninng RHEL3 and NFS. Clients are RHEL3 and 
FC1. We are having problems with an service that want's to change the 
executable bit on a file located on the NFS exported filesystem. The 
service is running on RHEL3.

Client:

Linux version 2.4.21-9.0.1.ELsmp (bhcompile@bugs.devel.redhat.com) (gcc 
version 3.2.3 20030502 (Red Hat Linux 3.2.3-26)) #1 SMP Mon Feb 9 
22:26:51 EST 2004
redhat-config-nfs-1.0.13-1
nfs-utils-1.0.6-21EL

Server:

Linux version 2.4.21-9.0.1.EL040519 (root@s1) (gcc version 3.2.3 
20030502 (Red Hat Linux 3.2.3-20)) #2 SMP Wed May 19 14:56:39 CEST 2004
redhat-config-nfs-1.0.13-1
nfs-utils-1.0.6-21EL


The results are strange and listed below:

Running the following script:

for i1 in 0 1 2 3 4 5 6 7 8 9 ; do
for i2 in 0 1 2 3 4 5 6 7 8 9 ; do
for i3 in 0 1 2 3 4 5 6 7 8 9 ; do
ls -l "$joboption_directory/test.sh" 1>&2
/bin/usleep 100000
done
done
done


Produce these results:

-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rw-------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh
-rwx------    1 auser auser       41 May 25 18:10 /disk/global/grid/
52341085501427351028959/test.sh


And then it stabilizes.

I have no clue to what the problem might be. Is it client or server 
related?

Many regards

Jonas Lindemann





-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
