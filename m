From: Grzegorz Tylenda <beh@freya.dsv.agh.edu.pl>
Subject: nfs client performance - 2.4 vs 2.6
Date: Wed, 7 Jun 2006 14:14:30 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0606071256140.17804@freya.dsv.agh.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fnwvm-0004gS-6W
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 05:14:38 -0700
Received: from freya.dsv.agh.edu.pl ([149.156.124.22] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fnwvj-0003xc-Mf
	for nfs@lists.sourceforge.net; Wed, 07 Jun 2006 05:14:38 -0700
Received: from localhost (localhost [127.0.0.1])
	by freya.dsv.agh.edu.pl (Postfix) with ESMTP id 8CD9D133956
	for <nfs@lists.sourceforge.net>; Wed,  7 Jun 2006 14:14:32 +0200 (CEST)
Received: from freya.dsv.agh.edu.pl ([127.0.0.1])
	by localhost (freya.dsv.agh.edu.pl [127.0.0.1]) (amavisd-new,
	port 10024) with ESMTP id 27989-03 for <nfs@lists.sourceforge.net>;
	Wed,  7 Jun 2006 14:14:30 +0200 (CEST)
Received: from localhost (localhost [127.0.0.1])
	by freya.dsv.agh.edu.pl (Postfix) with ESMTP id DDC72A51E7
	for <nfs@lists.sourceforge.net>; Wed,  7 Jun 2006 14:14:30 +0200 (CEST)
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

Hello,


I noticed that after kernel version was changed from 2.4 to 2.6 
on clients connecting to filer, number of nfs ops on the filer heavily 
increase (about 40%). Overall filer load increase too. Statistic for both kernel series are very 
different.


For example for 2 identical servers doing the same work, wchich differs 
only in kernel version generetes drasticly different number of 
NFSOPS:

12.456.678.8 	2.4-server            NFSOPS =     280165 ( 0%)
12.456.678.9 	2.6-server            NFSOPS =    3357591 ( 2%)


Per host statistics looks like that (NFSv2 are cuted off, since I use 
NFSv3 only):

filer*> nfsstat -h 2.4-server

Client: 12.456.678.8 (2.4-server) 
------------------------------------

Server rpc:
TCP:
calls       badcalls    nullrecv    badlen      xdrcall
280355      0           0           0           0

UDP:
calls       badcalls    nullrecv    badlen      xdrcall
0           0           0           0           0

Server nfs:
calls       badcalls
280355      0


Server nfs V3:
null       getattr    setattr    lookup     access     readlink   read
0 0%       131820 47% 0 0%       88459 32%  47558 17%  18 0%      12500 4%
write      create     mkdir      symlink    mknod      remove     rmdir
0 0%       0 0%       0 0%       0 0%       0 0%       0 0%       0 0%
rename     link       readdir    readdir+   fsstat     fsinfo     pathconf
0 0%       0 0%       0 0%       0 0%       0 0%       0 0%       0 0%
commit
0 0%

Read request stats (version 3)
0-511      512-1023   1K-2047    2K-4095    4K-8191    8K-16383 
16K-32767  32K-65535  64K-131071
0          0          0          0          3910       8590       0 
0          0
Write request stats (version 3)
0-511      512-1023   1K-2047    2K-4095    4K-8191    8K-16383 
16K-32767  32K-65535  64K-131071
0          0          0          0          0          0          0 
0          0



filer*> nfsstat -h 2.6-server

Client: 12.456.678.9 (2.6-server) 
------------------------------------

Server rpc:
TCP:
calls       badcalls    nullrecv    badlen      xdrcall
3365218     0           0           0           0

UDP:
calls       badcalls    nullrecv    badlen      xdrcall
0           0           0           0           0

Server nfs:
calls       badcalls
3365218     0

Server nfs V3:
null       getattr    setattr    lookup     access     readlink   read
0 0%       52092 2%   0 0%       51149 2%   3253489 97% 6 0%       8482 0%
write      create     mkdir      symlink    mknod      remove     rmdir
0 0%       0 0%       0 0%       0 0%       0 0%       0 0%       0 0%
rename     link       readdir    readdir+   fsstat     fsinfo     pathconf
0 0%       0 0%       0 0%       0 0%       0 0%       0 0%       0 0%
commit
0 0%

Read request stats (version 3)
0-511      512-1023   1K-2047    2K-4095    4K-8191    8K-16383 
16K-32767  32K-65535  64K-131071
330        207        342        593        860        6150       0 
0          0
Write request stats (version 3)
0-511      512-1023   1K-2047    2K-4095    4K-8191    8K-16383 
16K-32767  32K-65535  64K-131071
0          0          0          0          0          0          0 
0          0



As you can see on 2.6 kernel, about 97% are "access" request, while on 
2.4 "access" are only 17%. Where this differences came 
from? Why 2.6 kernels generates 10x more request then 2.4?

Client mounting opions are:
ro,v3,rsize=8192,wsize=8192,acregmin=85,acregmax=180,acdirmin=85,acdirmax=180,hard,intr,nocto,lock,proto=tcp

Changin rsize and wsize to 32k does not help, also different version of 
2.6 series does not make a diffrence (curently 2.6.16.18) :(

I will be grateful for any help.

-- 
Best regards
Grzesiek Tylenda



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
