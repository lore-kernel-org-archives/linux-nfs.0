From: "Martin L. Purschke" <purschke@bnl.gov>
Subject: nfs stalls on cp with certain file sizes with jumbo-gigabit
Date: Sun, 28 Dec 2003 15:50:14 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FEF4206.7070300@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AahrS-0004oA-HR
	for nfs@lists.sourceforge.net; Sun, 28 Dec 2003 12:50:06 -0800
Received: from smtpgw3.bnl.gov ([130.199.3.20])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AahrS-0005GL-2H
	for nfs@lists.sourceforge.net; Sun, 28 Dec 2003 12:50:06 -0800
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


Hello,

I have a few linux nfs servers, all identical, dual gigabit NIC's, one
on mtu 1500 and one on another jumbo-frame network. I have dozens of nfs
clients on the regular network and never had a problem. I recently
started to move machines to the jumbo-frame network. I came across a
strange problem that a nfs client stalls when cp'ing a file with a
certain file size. (There are many other ways to get the nfs client to
stall that has so far prevented me from deploying machines on the
J-network, but this one is easily reproducible).

I tracked down a file that would cause the problem. I made another file
with the exact same size and could reproduce the error (so it's not the
particular file, but the size that does it). The size happens to be 4698
bytes, here is a strace of the cp command of the special-made file with
that exact length:

> [root@va033 tmp]# strace cp /root/4698.dat .
> execve("/bin/cp", ["cp", "/root/4698.dat", "."], [/* 45 vars */]) = 0
> uname({sys="Linux", node="va033.phenix.bnl.local", ...}) = 0
>
> ....
>
> lstat64(".", {st_mode=S_IFDIR|0777, st_size=4096, ...}) = 0
> stat64(".", {st_mode=S_IFDIR|0777, st_size=4096, ...}) = 0
> stat64("/root/4698.dat", {st_mode=S_IFREG|0644, st_size=4698, ...}) = 0
> stat64("./4698.dat", {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
> open("/root/4698.dat", O_RDONLY|O_LARGEFILE) = 3
> fstat64(3, {st_mode=S_IFREG|0644, st_size=4698, ...}) = 0
> open("./4698.dat", O_WRONLY|O_TRUNC|O_LARGEFILE) = 4
> fstat64(4, {st_mode=S_IFREG|0644, st_size=0, ...}) = 0
> fstat64(3, {st_mode=S_IFREG|0644, st_size=4698, ...}) = 0
> read(3, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
> 32768) = 4698
> write(4, "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0"...,
> 4698) = 4698
> read(3, "", 32768)                      = 0
> close(4

and there is hangs indefinitely. I have no problem doing the exact same
thing on the mtu=1500 network, in fact, I dropped the jumbo network down
to 1500 and the same operation works.

Both client and server run kernel 2.4.22 with SMP and high-mem
nfs is:  type nfs
(rw,nfsvers=3,hard,wsize=32768,rsize=32768,addr=192.168.30.6)
I played with the sizes, no effect.

Does this ring a bell? I looked in this list and saw some of Trond's
patches, but the errors they address were different, and I'm not sure if
I need to look in the network drivers instead. I'm  planning to install
the patches as advised in
http://sourceforge.net/mailarchive/message.php?msg_id=6283173
but these are production machines, and the patches are tagged
"experimental". Any advice is highly appreciated.

Thanks,
   Martin

-- 
Martin L. Purschke               ;   purschke@bnl.gov
                                 ;   http://www.phenix.bnl.gov/~purschke
                                 ;
Brookhaven National Laboratory   ;   phone: +1-631-344-5244
Physics Department Bldg 510 C    ;   fax:   +1-631-344-3253
Upton, NY 11973-5000             ;
-----------------------------------------------------------------------




-------------------------------------------------------
This SF.net email is sponsored by: IBM Linux Tutorials.
Become an expert in LINUX or just sharpen your skills.  Sign up for IBM's
Free Linux Tutorials.  Learn everything from the bash shell to sys admin.
Click now! http://ads.osdn.com/?ad_id=1278&alloc_id=3371&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
