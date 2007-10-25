From: Andreas Schuldei <andreas@schuldei.org>
Subject: nfs performance problem
Date: Thu, 25 Oct 2007 15:10:29 +0200
Message-ID: <20071025131029.GH8334@barnabas.schuldei.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il2qC-0003TT-NU
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 06:33:41 -0700
Received: from petrus.schuldei.org ([81.27.3.162] helo=barnabas.schuldei.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Il2qH-0000hf-MW
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 06:33:46 -0700
Received: from localhost (localhost [127.0.0.1])
	by barnabas.schuldei.org (Postfix) with ESMTP id 5576914C199
	for <nfs@lists.sourceforge.net>; Thu, 25 Oct 2007 15:10:35 +0200 (CEST)
Received: from barnabas.schuldei.org ([127.0.0.1])
	by localhost (barnabas.schuldei.org [127.0.0.1]) (amavisd-new,
	port 10024)
	with LMTP id WY8c6jto8sYC for <nfs@lists.sourceforge.net>;
	Thu, 25 Oct 2007 15:10:31 +0200 (CEST)
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

Hi!

I need to tune a nfs server and client. on the server we have
several Tbyte of ~2Mbyte files and we need to transfer them read
only to the client. latency and throughput are crucial.

What nfs server should i use? i started with the
nfs-kernel-server on top of a kernel 2.6.22 on debian on the
server side. the client is a debian etch server (2.6.18 kernel)
with 1Gbyte e1000 intel network driver. later on we consider two
network cards on both machines to transfer 2Gbit/s. Jumboframes
are an option (how much will they help?)

Right now i have only four disks in the server and i get 50Mbyte
out of each of them, simultaniously, for real world loads (random
reads across the disk, trying to minimizing the seeks by reading
the files in one go with

for i in a b h i ; do ( find /var/disks/sd$i -type f | xargs -I=B0 dd if=3D=
=B0 bs=3D2M of=3D/dev/null status=3Dnoxfer 2>/dev/null & ) ; done

so with this (4*50 Mbyte/s) i should be able to saturate both
network cards.

accessing the disks with apache2-mpm-worker we get ~90Mbyte/s out
of the server, partly with considerable latency in the order of
magnitude of 10s.

I was hoping to get at least the same performance with much
better latency with nfs.

on the server i start 128 nfs servers (RPCNFSDCOUNT=3D128) and export
the disks like this:

/usr/sbin/exportfs -v
/var/disks/sda <world>(ro,async,wdelay,root_squash,no_subtree_check,anonuid=
=3D65534,anongid=3D65534)
/var/disks/sdb <world>(ro,async,wdelay,root_squash,no_subtree_check,anonuid=
=3D65534,anongid=3D65534)
/var/disks/sdh <world>(ro,async,wdelay,root_squash,no_subtree_check,anonuid=
=3D65534,anongid=3D65534)
/var/disks/sdi <world>(ro,async,wdelay,root_squash,no_subtree_check,anonuid=
=3D65534,anongid=3D65534)


on the client i mount them like this:

lotta:/var/disks/sda on /var/disks/sda type nfs (ro,hard,intr,proto=3Dtcp,r=
size=3D32k,addr=3D217.213.5.44)
lotta:/var/disks/sdb on /var/disks/sdb type nfs (ro,hard,intr,proto=3Dtcp,r=
size=3D32k,addr=3D217.213.5.44)
lotta:/var/disks/sdh on /var/disks/sdh type nfs (ro,hard,intr,proto=3Dtcp,r=
size=3D32k,addr=3D217.213.5.44)
lotta:/var/disks/sdi on /var/disks/sdi type nfs (ro,hard,intr,proto=3Dtcp,r=
size=3D32k,addr=3D217.213.5.44)

but when i then do the same dd again on the client i get
disappointing 60-70Mbyte/s altogether. from a single disk i get
~25Mbytes/s on the client side.

i played with some buffers /proc/sys/net/core/rmem_max and
/proc/sys/net/core/rmem_default and increased them to 256M on the
client.

i was suspecting that the nfs server reads the files in too small
chunks and tried to help it with =


for i in a  h i  ; do ( echo $((1024*6)) > /sys/block/sd$i/queue/read_ahead=
_kb ) ; done

to get it to read in the files in one go.

I would hope to at least double the speed. do
you have a benchmark tool that can tell me the latency? i tried
iozone and tried forcing it to only do read tests and did not get
any helpfull error or output at all. =



on the server:

nfsstat
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
98188885   0          0          0          0

Server nfs v3:
null         getattr      setattr      lookup       access       readlink
5599      0% 318417    0% 160       0% 132643    0% 227130    0% 0         =
0%
read         write        create       mkdir        symlink      mknod
97256921 99% 118313    0% 168       0% 0         0% 0         0% 0         =
0%
remove       rmdir        rename       link         readdir      readdirplus
162       0% 0         0% 0         0% 0         0% 0         0% 105556    =
0%
fsstat       fsinfo       pathconf     commit
0         0% 1270      0% 0         0% 7153      0%



cat /proc/net/rpc/nfsd
rc 0 118803 98069945
fh 0 0 0 0 0
io 3253902194 38428672
th 128 10156908 1462.848 365.212 302.100 252.204 311.632 187.508 142.708 14=
2.132 198.168 648.640
ra 256 97097262 0 0 0 0 0 0 0 0 0 64684
net 98188985 16 98188854 5619
rpc 98188885 0 0 0 0
proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 5599 318417 160 132643 227130 0 97256921 118313 168 0 0 0 162 0 0 =
0 0 105556 0 1270 0 7153
proc4 2 0 0
proc4ops 40 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0=
 0 0 0 0 0 0 0 0






-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
