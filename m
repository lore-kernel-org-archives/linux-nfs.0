From: Alan Powell <lakerfaniam2@yahoo.com>
Subject: nfsd tuning - please help me!
Date: Thu, 13 Feb 2003 14:24:49 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030213222449.86494.qmail@web12208.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web12208.mail.yahoo.com ([216.136.173.92])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18jRmj-0006qJ-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Feb 2003 14:24:49 -0800
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

Linux NFS gurus: I need your help! I've spent the
better part of the week trying to tune our NFS server.
It's serving about 30Mbit/sec sustained, but the
latency for serving NFS requests is high. When I
access an NFS mount from a client machine, it can
sometimes take several seconds to do even a simple
directory listing. However, doing the same operations
on the NFS server locally is always fast, even if I'm
doing the operation from an NFS client that is under
minimal load. So I'm pretty sure that the problem is
NFS server specific. Furthermore, I'm pretty sure that
this is not a hardware issue, so my question is if we
are just running the Linux NFS daemon up to its
limits? WAt this point we're very close to buying a
NetApp filer to alleviate the problem, b/c I've heard
some amazing stats from their salespeople, but I
wanted to check with you guys first. Thank you!

Here's some more info:
- We're using the latest RH 7.3 kernel
(2.4.18-24.7.xsmp) on both the server and clients.
- We use only NFS v3.
- For the most part of the day, we're serving about
100 random 30KB file reads per second (minimal
writes), resulting in 30Mbit transfer.
- We are not hardware constrained (CPU is 90% idle,
and the disks perform fine when doing local file
operations). The latency only occurs for NFS
operations.
- There are no network issues (there are hardly any
retransmissions according to nfsstat). Also, using
ttcp to test the network connection, we're able to
utilize the remaining 70Mbit on the ethernet card.
- We have a max limit of 32 NFS daemon processes, and
according to /proc/net/rpc/nfsd, that is more than we
need.
- NFS is mounted with the following options, and
increasing [rw]size beyond 8192 has made no
difference: rw,hard,rsize=8192,wsize=8192,actimeo=120 
- Adjusting [rw]mem_default and [rw]mem_max in
/proc/sys/net/core beyond the default 64KB has made no
difference.

I rebooted the NFS server about 20 hours ago, and here
are nfsstat and iostat numbers for it since the
counters were cleared out 20 hours ago:

[root@server etc]# nfsstat -s
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
47303390   0          0          0          0       

Server nfs v3:
null       getattr    setattr    lookup     access    
readlink   
0       0% 12498418 26% 16824   0% 7556878 15% 224714 
0% 54      0% 
read       write      create     mkdir      symlink   
mknod      
26663116 56% 225950  0% 19573   0% 1       0% 0      
0% 0       0% 
remove     rmdir      rename     link       readdir   
readdirplus
7936    0% 0       0% 14880   0% 248     0% 36450   0%
605     0% 
fsstat     fsinfo     pathconf   commit     
14      0% 37      0% 0       0% 37766   0% 


[root@server etc]# iostat -x
Linux 2.4.18-24.7.xsmp (server.domain.com)  02/13/2003

avg-cpu:  %user   %nice    %sys   %idle
           0.27    0.01    7.78   91.94

Device:    rrqm/s wrqm/s   r/s   w/s  rsec/s  wsec/s  
 rkB/s    wkB/s avgrq-sz avgqu-sz   await  svctm 
%util
/dev/rd/c0d0
           280.34   6.17  0.00  0.00 5172.83   67.25 
2586.41    33.63     0.00     0.29    0.00   0.00 
10.37


__________________________________________________
Do you Yahoo!?
Yahoo! Shopping - Send Flowers for Valentine's Day
http://shopping.yahoo.com


-------------------------------------------------------
This SF.NET email is sponsored by: FREE  SSL Guide from Thawte
are you planning your Web Server Security? Click here to get a FREE
Thawte SSL guide and find the answers to all your  SSL security issues.
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0026en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
