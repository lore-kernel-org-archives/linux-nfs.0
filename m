From: Stephan Koledin <skoledin@neolinear.com>
Subject: NFS lockups with 2.4.18
Date: Wed, 24 Sep 2003 12:51:22 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F71CB8A.3090208@neolinear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2CrN-0001jS-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 09:51:25 -0700
Received: from n5.neolinear.com ([208.20.218.5] helo=flood.neolinear.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2CrM-0004Rk-R2
	for nfs@lists.sourceforge.net; Wed, 24 Sep 2003 09:51:24 -0700
Received: from rain ([192.9.200.77])
	by flood.neolinear.com with esmtp (Exim 3.35 #1 (Debian))
	id 1A2CrK-0007Xl-00
	for <nfs@lists.sourceforge.net>; Wed, 24 Sep 2003 12:51:22 -0400
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello All-

We're running into some NFS lockups here and having a rough time 
debugging/solving the issue. I'm hoping that someone on the list may be 
able to provide some suggestions.

Background:

Unpredictably, but approximately every week or two, we run into a 
problem where our file server stops responding to NFS requests. The 
server is Debian 3.0 (woody), running the 2.4.18-1-686 stock debian 
kernel. Have also seen the same problem with the debian bf2.4 kernel.
Server is a single 2.6GHz P4 processor, >1GB RAM, with several large 
(>500GB) SCSI-160 arrays using ext3 filesystems, quotas enabled.

The problem only seems to be resolvable with a reboot, and even then, 
the problem will often reoccur within a few minutes, requiring another 
reboot (1-5 times), before finally settling down and being stable for 
1-14+ days.

We have not noticed anything strange/interesting in any of the logs or 
on the console. All other services/processes on the machine continue to 
operate perfectly, including disk operations. The machine simply stops 
serving NFS.

We serve NFS to Linux, Solaris, and HP clients, several versions of each OS.

Some Relevant Data (from when NFS was not working properly):

$ rpcinfo -p

    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100029    1   udp    845  keyserv
     100029    2   udp    845  keyserv
     100011    1   udp    852  rquotad
     100011    2   udp    852  rquotad
     100011    1   tcp    855  rquotad
     100011    2   tcp    855  rquotad
     100024    1   udp  32772  status
     100024    1   tcp  32768  status
     100001    1   udp  32773  rstatd
     100001    2   udp  32773  rstatd
     100001    3   udp  32773  rstatd
     100001    4   udp  32773  rstatd
     100001    5   udp  32773  rstatd
     100003    2   udp   2049  nfs
     100003    3   udp   2049  nfs
     100021    1   udp  32774  nlockmgr
     100021    3   udp  32774  nlockmgr
     100021    4   udp  32774  nlockmgr
     100005    1   udp  32775  mountd
     100005    1   tcp  32769  mountd
     100005    2   udp  32775  mountd
     100005    2   tcp  32769  mountd
     100005    3   udp  32775  mountd
     100005    3   tcp  32769  mountd

$ rpcinfo [-u | -t] <host> <program>

portmapper udp
program 100000 version 2 ready and waiting
portmapper tcp
program 100000 version 2 ready and waiting

keyserv
program 100029 version 1 ready and waiting
program 100029 version 2 ready and waiting

rquotad udp
program 100011 version 1 ready and waiting
program 100011 version 2 ready and waiting
rquotad tcp
program 100011 version 1 ready and waiting
program 100011 version 2 ready and waiting

status udp
program 100024 version 1 ready and waiting
status tcp
program 100024 version 1 ready and waiting

rstatd udp
program 100001 version 1 ready and waiting
program 100001 version 2 ready and waiting
program 100001 version 3 ready and waiting
program 100001 version 4 is not available
program 100001 version 5 ready and waiting

nfs udp
program 100003 version 0 is not available

nlockmgr udp
program 100021 version 0 is not available

mountd udp
program 100005 version 0 is not available
mountd tcp
program 100005 version 0 is not available


(normal output, as expected, is as follows)
nfs udp
program 100003 version 2 ready and waiting
program 100003 version 3 ready and waiting

nlockmgr udp
program 100021 version 1 ready and waiting
program 100021 version 2 is not available
program 100021 version 3 ready and waiting
program 100021 version 4 ready and waiting

mountd udp
program 100005 version 1 ready and waiting
program 100005 version 2 ready and waiting
program 100005 version 3 ready and waiting
mountd tcp
program 100005 version 1 ready and waiting
program 100005 version 2 ready and waiting
program 100005 version 3 ready and waiting


All nfsd processes (32) are still in process list, but the number of 
swapped processes reported by vmstat jumps from 2 to 33, right around 
the occurrence of the problem. The rpc.mountd, rpc.rquotad, and 
rpc.statd processes are also still in the process list along with the 32 
nfsd instances. Don't see anything unusual in any of the other system 
stats - memory, cpu, and disk usage all remain steady. Memory 
utilization graphs during the problem period appear flatter than is 
typical, but not much change in values from normal operation.

Does anyone have any ideas about the problem? I'll be sure to grab some 
nfsstat and better ps output next time this happens, but any other 
suggestions for better logging or any other relevant data collection? 
Have there been any fixes since 2.4.18 that address similar or related 
problems?

Thanks for any help with this elusive problem.

-Stephan

-- 
Stephan B Koledin
Network Systems Developer
http://neolinear.com/



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
