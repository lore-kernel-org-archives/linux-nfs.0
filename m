From: "Damien \"zaide\"" <list@zaide.org>
Subject: NFS blocked
Date: Wed, 09 Feb 2005 11:30:05 +0100
Message-ID: <4209E62D.5040203@zaide.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cyp6n-0001RY-3e
	for nfs@lists.sourceforge.net; Wed, 09 Feb 2005 02:30:09 -0800
Received: from postfix4-1.free.fr ([213.228.0.62])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cyp6l-00030K-JE
	for nfs@lists.sourceforge.net; Wed, 09 Feb 2005 02:30:08 -0800
Received: from [192.168.2.7] (diderot-4-81-57-120-45.fbx.proxad.net [81.57.120.45])
	by postfix4-1.free.fr (Postfix) with ESMTP id B560228C190
	for <nfs@lists.sourceforge.net>; Wed,  9 Feb 2005 11:30:04 +0100 (CET)
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

I have a strange problem on my nfsv3 all work fine but when i try to cat 
a file inside a mounted nfs partition who work with apache's session i 
get this problem:

$ strace cat /web/tmp/sess_231f9a00283f90be0ddd9a19e583f492
execve("/bin/cat", ["cat", 
"/web/tmp/sess_231f9a00283f90be0ddd9a19e583f492"], [/* 18 vars */]) = 0
....
open("/web/tmp/sess_231f9a00283f90be0ddd9a19e583f492", 
O_RDONLY|O_LARGEFILE) = 3
fstat64(3, {st_mode=S_IFREG|0600, st_size=13, ...}) = 0
read(3, "cmp|i:0;", 32768)         = 13
write(1, "cmp|i:0;", 13cmp|i:0;)           = 13
read(3, "", 32768)                      = 0
brk(0)                                  = 0x8073000
brk(0)                                  = 0x8073000
brk(0x8072000)                          = 0x8072000
brk(0)                                  = 0x8072000
close(3

and that all, it is blocked to the close() function.

my process:
test-cl   8678  0.0  0.0  1724  564 pts/4    S+   10:52   0:00 strace 
cat /web/tmp/sess_231f9a00283f90be0ddd9a19e583f492
test-cl  19613  0.0  0.0  1824  432 pts/4    D+   10:52   0:00 cat 
/web/tmp/sess_231f9a00283f90be0ddd9a19e583f492

my mounted partitions:
nfsserver:/data1/web/tmp on /web/tmp type nfs 
(rw,noexec,nosuid,addr=172.16.8.100)

and in my log:
Feb  9 11:24:35 nfs-client kernel: lockd: server 172.16.8.100 not 
responding, still trying

that all i have, so do you have any solutions, do you have allready seen 
this?



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
