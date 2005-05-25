From: Anton Starikov <A.Starikov@utwente.nl>
Subject: NFS cache problem
Date: Thu, 26 May 2005 01:01:14 +0200
Message-ID: <429503BA.4060908@utwente.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Db4tx-00078a-Oz
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 16:03:01 -0700
Received: from netlx014.civ.utwente.nl ([130.89.1.88])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Db4tw-0007S3-1o
	for nfs@lists.sourceforge.net; Wed, 25 May 2005 16:03:01 -0700
Received: from [130.89.204.129] (hantst.kabel.utwente.nl [130.89.204.129])
          by netlx014.civ.utwente.nl (8.11.7/HKD) with ESMTP id j4PN1Kp31701
          for <nfs@lists.sourceforge.net>; Thu, 26 May 2005 01:01:20 +0200
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

I have fileserver exporting via NFSv3 /home directories to few desktops
and small cluster. File server has two NICs, one for cluster, one for
desktops. Kernel version is 2.6.5.


export options are (exportfs -v):
/home           192.168.211.0/24(rw,async,no_root_squash)

mount options are (cat /proc/mounts):
192.168.211.240:/home /home nfs
rw,sync,v3,rsize=32768,wsize=32768,acregmin=0,acregmax=0,acdirmin=0,acdirmax=0,hard,intr,tcp,noac,lock,addr=192.168.211.240
0 0

Time on all clients (desktops and cluster) are synchronized via NTP.

But time to time I have strange situation. You can rewrite file at one
host, but for long time (up to few hours!!!) some hosts will read new
file, some hosts will read old file.

I tried to play with all options without any result. Exporting with
"sync" seems to be a sollution, but performance is really very low
(because of this "sync" wasn't realy tested). And and I don't need
"sync" because I'm not interesting in saving to "real" media.
File-cache is good enough for me. And, in principal, "syns/async" on
server side should be irrelevant in this case (at least on client side I
have "sync", it's enough).

To avoid future discussion, there is nothing "cluster specific". Cluster
is very small and  there is nothing like concurent read/write.
Basically, only one specific thing, the same data can be accesible from
different host. But even not at the same time usually.
You write file on one host, let say, and in couple minutes you read it
from different host (you prepare input data on client host or master
node and after you submit job into the queue). That should be OK, but in
my case...up to few hours clients can see chaos by reading different
versions of file.

Does anybody has some ideas how to solve the problem?

BTW, hardware configuration.
server:
3ware SATA raid, 2xXeon CPUs (NFSD started in 8 threads). Intel and
Broadcom GbE NICs.

Clients - mostly dual Opteron machines.

Actually, I have strong filling that problem started to be much more
"visible" when I have added second CPU to server. It exists before, but
usually not longer that for 10 minutes. Now my users report me about
hours. This is incredible. Basically, work in my group partly paralysed
now :(

Of course there is such things like lustre, PVFS and so on. But I
beleive that my case isn't proper case to start use such filesystems.
NFS should be more than enough.

Thanks,
	Anton Starikov.



-------------------------------------------------------
SF.Net email is sponsored by: GoToMeeting - the easiest way to collaborate
online with coworkers and clients while avoiding the high cost of travel and
communications. There is no equipment to buy and you can meet as often as
you want. Try it free.http://ads.osdn.com/?ad_id=7402&alloc_id=16135&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
