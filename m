From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs performance problem
Date: Thu, 25 Oct 2007 11:25:37 -0400
Message-ID: <7B68ECC3-7EBA-442F-9FFD-A0E3F2DCC61A@oracle.com>
References: <20071025131029.GH8334@barnabas.schuldei.org>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
To: Andreas Schuldei <andreas@schuldei.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Il5sT-0001yw-Dy
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 09:48:13 -0700
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Il5sV-0002Ci-OV
	for nfs@lists.sourceforge.net; Thu, 25 Oct 2007 09:48:18 -0700
In-Reply-To: <20071025131029.GH8334@barnabas.schuldei.org>
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

On Oct 25, 2007, at 9:10 AM, Andreas Schuldei wrote:
> Hi!
>
> I need to tune a nfs server and client. on the server we have
> several Tbyte of ~2Mbyte files and we need to transfer them read
> only to the client. latency and throughput are crucial.
>
> What nfs server should i use? i started with the
> nfs-kernel-server on top of a kernel 2.6.22 on debian on the
> server side. the client is a debian etch server (2.6.18 kernel)
> with 1Gbyte e1000 intel network driver. later on we consider two
> network cards on both machines to transfer 2Gbit/s. Jumboframes
> are an option (how much will they help?)
>
> Right now i have only four disks in the server and i get 50Mbyte
> out of each of them, simultaniously, for real world loads (random
> reads across the disk, trying to minimizing the seeks by reading
> the files in one go with
>
> for i in a b h i ; do ( find /var/disks/sd$i -type f | xargs -I=B0 dd  =

> if=3D=B0 bs=3D2M of=3D/dev/null status=3Dnoxfer 2>/dev/null & ) ; done
>
> so with this (4*50 Mbyte/s) i should be able to saturate both
> network cards.
>
> accessing the disks with apache2-mpm-worker we get ~90Mbyte/s out
> of the server, partly with considerable latency in the order of
> magnitude of 10s.
>
> I was hoping to get at least the same performance with much
> better latency with nfs.

With a single client, you should not expect to get any better  =

performance than by running the web service on the NFS server.  The  =

advantage of using NFS under a web service is that you can  =

transparently scale horizontally.  When you add a second or third web  =

server that serves the same file set, you will see an effective  =

increase in the size of the data cache between your NFS server's  =

disks and the web servers.

But don't expect to get better data throughput over NFS than you see  =

on your local NFS server.  If anything, the 10s latency you see when  =

the web server is on the same system with the disks is indicative of  =

local file system configuration issues.

> on the server i start 128 nfs servers (RPCNFSDCOUNT=3D128) and export
> the disks like this:
>
> /usr/sbin/exportfs -v
> /var/disks/sda <world> =

> (ro,async,wdelay,root_squash,no_subtree_check,anonuid=3D65534,anongid=3D6=
5 =

> 534)
> /var/disks/sdb <world> =

> (ro,async,wdelay,root_squash,no_subtree_check,anonuid=3D65534,anongid=3D6=
5 =

> 534)
> /var/disks/sdh <world> =

> (ro,async,wdelay,root_squash,no_subtree_check,anonuid=3D65534,anongid=3D6=
5 =

> 534)
> /var/disks/sdi <world> =

> (ro,async,wdelay,root_squash,no_subtree_check,anonuid=3D65534,anongid=3D6=
5 =

> 534)

On the server, mounting the web data file systems with "noatime" may  =

help reduce the number of seeks on the disks.

Also, the "async" export option won't have any effect on reads.

Check your block device configuration as well.  You may find that  =

varying the RAID configuration, file system type (ext3 v. xfs) and  =

stripe/chunk size could impact your server's performance.  You might  =

find that the deadline disk scheduler performs a little better than  =

the default cfq scheduler.

It goes without saying that you should make sure your disk subsystem  =

is healthy.  I've found that, for example, SATA drives in hot-swap  =

enclosures are sometimes affected by silent SATA transport errors  =

that result in slow performance.  Check dmesg carefully to ensure you  =

are getting the highest possible speed settings.  If only one of your  =

drives is running significantly slower than the others, it will have  =

a significant impact on the performance of a RAID group.

> on the client i mount them like this:
>
> lotta:/var/disks/sda on /var/disks/sda type nfs  =

> (ro,hard,intr,proto=3Dtcp,rsize=3D32k,addr=3D217.213.5.44)
> lotta:/var/disks/sdb on /var/disks/sdb type nfs  =

> (ro,hard,intr,proto=3Dtcp,rsize=3D32k,addr=3D217.213.5.44)
> lotta:/var/disks/sdh on /var/disks/sdh type nfs  =

> (ro,hard,intr,proto=3Dtcp,rsize=3D32k,addr=3D217.213.5.44)
> lotta:/var/disks/sdi on /var/disks/sdi type nfs  =

> (ro,hard,intr,proto=3Dtcp,rsize=3D32k,addr=3D217.213.5.44)

There are some client-side mount options that might also help.  Using  =

"nocto" and "actimeo=3D7200" could reduce synchonous NFS protocol  =

overhead.  I also notice a significant amount of readdirplus  =

traffic.  Readdirplus requests are fairly heavyweight, and in this  =

scenario may be unneeded overhead.  Your client might support the  =

recently added "nordirplus" mount option, which could be helpful.

I wonder if "rsize=3D32k" is supported - you might want "rsize=3D32768"  =

instead.  Or better, let the client and server negotiate the maximum  =

that each supports automatically by leaving this option off.  You can  =

check what options are in effect on each NFS mount point by looking  =

in /proc/self/mountstats on the client.

Enabling jumbo frames between your NFS server and client will help.   =

Depending on your NIC, though, it may introduce some instability  =

(driver and hardware mileage may vary).

Since you currently have only one client, you might consider running  =

the client and server back-to-back (ie replace any hub or switch with  =

a simple cross-over link) to eliminate extra network overhead.   =

Getting a high performance switch when you add more clients is key to  =

making this configuration scale well -- a $99 special won't cut it.

> but when i then do the same dd again on the client i get
> disappointing 60-70Mbyte/s altogether. from a single disk i get
> ~25Mbytes/s on the client side.

25MB/s is fairly typical for Linux NFS servers.

> i played with some buffers /proc/sys/net/core/rmem_max and
> /proc/sys/net/core/rmem_default and increased them to 256M on the
> client.

You should consider similar network tuning on the server.  Use a  =

network benchmarking tool like iperf to assist.

> i was suspecting that the nfs server reads the files in too small
> chunks and tried to help it with
>
> for i in a  h i  ; do ( echo $((1024*6)) > /sys/block/sd$i/queue/ =

> read_ahead_kb ) ; done
>
> to get it to read in the files in one go.

Insufficient read-ahead on your server may be an issue here.  Read  =

traffic from the client often arrives at the server out of order,  =

preventing the server from cleanly detecting sequential reads.  I  =

believe there was a recent change to the NFS server that addresses  =

this issue.

> I would hope to at least double the speed.

IMO you can do that only by adding more clients.

> do
> you have a benchmark tool that can tell me the latency? i tried
> iozone and tried forcing it to only do read tests and did not get
> any helpfull error or output at all.

Use "iozone -a -i 1" to run read tests.  You can narrow the test down  =

to 2MB sequential reads if you want.  Take a look at "iozone -h"  =

output for more details.

> on the server:
>
> nfsstat
> Server rpc stats:
> calls      badcalls   badauth    badclnt    xdrcall
> 98188885   0          0          0          0
>
> Server nfs v3:
> null         getattr      setattr      lookup       access        =

> readlink
> 5599      0% 318417    0% 160       0% 132643    0% 227130    0%  =

> 0         0%
> read         write        create       mkdir        symlink      mknod
> 97256921 99% 118313    0% 168       0% 0         0% 0         0%  =

> 0         0%
> remove       rmdir        rename       link         readdir       =

> readdirplus
> 162       0% 0         0% 0         0% 0         0% 0         0%  =

> 105556    0%
> fsstat       fsinfo       pathconf     commit
> 0         0% 1270      0% 0         0% 7153      0%
>
>
>
> cat /proc/net/rpc/nfsd
> rc 0 118803 98069945
> fh 0 0 0 0 0
> io 3253902194 38428672
> th 128 10156908 1462.848 365.212 302.100 252.204 311.632 187.508  =

> 142.708 142.132 198.168 648.640
> ra 256 97097262 0 0 0 0 0 0 0 0 0 64684
> net 98188985 16 98188854 5619
> rpc 98188885 0 0 0 0
> proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
> proc3 22 5599 318417 160 132643 227130 0 97256921 118313 168 0 0 0  =

> 162 0 0 0 0 105556 0 1270 0 7153
> proc4 2 0 0
> proc4ops 40 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0  =

> 0 0 0 0 0 0 0 0 0 0 0 0

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
