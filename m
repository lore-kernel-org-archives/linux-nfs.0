From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Strange delays on NFS server
Date: Wed, 11 Aug 2004 11:55:17 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4119FB15.7010205@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BuqlN-00015u-MX
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 03:55:21 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BuqlN-0003ML-5G
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 03:55:21 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:46831)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1BuqlJ-0004P1-BX
	for <nfs@lists.sourceforge.net>; Wed, 11 Aug 2004 11:55:17 +0100
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


Dear All

I am getting strange delays on our NFS server. Everything will
be fine for maybe 5 to 10 minutes, then saving a small text file
from a client machine will suddenly take 15 seconds or more.
Similarly, mozilla will pause accessing a page for ages ~30secs
(I assume it's poking about in ~/.mozilla). Everything pops back to 
normal afterwards. NFS server is lightly used at the moment.

System is running Fedora Core1 (2188 kernel), 3ware 7500 raid, ext3.
I have 32 nfsd processes, running NFS V3/tcp, 8192 block size,
single duplex 100Mbit etherpro. Clients have similar OS/mount opts.

I noticed a possible link to this:

http://sourceforge.net/mailarchive/message.php?msg_id=9080621

Anyone care to comment?

On the NFS FAQ it suggests raising:

# echo 262144 > /proc/sys/net/core/rmem_default
# echo 262144 > /proc/sys/net/core/rmem_max

Mine are 65536 and 131071 respectively, but the FAQ gives
strong caveats about doing this.

Here is the stats off the server (I haven't rebooted since
I switched to V3):

root@dunnet ipv4]# nfsstat -s
Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
1699297854   2          2          0          0
Server nfs v2:
null       getattr    setattr    root       lookup     readlink
907181  1% 19385896 29% 375501  0% 0       0% 5647809  8% 7246    0%
read       wrcache    write      create     remove     rename
24270181 37% 0       0% 13513519 20% 261062  0% 321986  0% 64110   0%
link       symlink    mkdir      rmdir      readdir    fsstat
119741  0% 2444    0% 1372    0% 2242    0% 125821  0% 45434   0%

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
2894636  0% 61177594  3% 1701443  0% 15723650  0% 39582580  2% 47421   0%
read       write      create     mkdir      symlink    mknod
1428854462 87% 71166229  4% 763544  0% 4621    0% 18314   0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
602276  0% 1631    0% 326031  0% 169218  0% 115075  0% 698649  0%
fsstat     fsinfo     pathconf   commit
54385   0% 72137   0% 2       0% 10272411  0%

Any suggestions ?


Thanks

Ian
-- 
Ian Thurlbeck                http://www.stams.strath.ac.uk/
Statistics and Modelling Science, University of Strathclyde
Livingstone Tower, 26 Richmond Street, Glasgow, UK,  G1 1XH
Tel: +44 (0)141 548 3667           Fax: +44 (0)141 552 2079



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
