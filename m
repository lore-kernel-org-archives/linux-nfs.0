From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Re: Strange delays on NFS server
Date: Wed, 25 Aug 2004 11:36:26 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412C6BAA.8010900@stams.strath.ac.uk>
References: <411CD601.1080308@RedHat.com> <4120AB46.1080606@stams.strath.ac.uk> <20040816131434.GL3510@suse.de> <4120C8D5.3040606@stams.strath.ac.uk> <20040816145435.GQ3510@suse.de> <4124CD95.7020007@stams.strath.ac.uk> <20040820095854.GC23176@suse.de> <412B0EDE.5010206@stams.strath.ac.uk> <20040825020241.GB16037@sgi.com> <412C5084.9050605@stams.strath.ac.uk> <20040825100227.GB16483@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzvAX-0002ga-Ob
	for nfs@lists.sourceforge.net; Wed, 25 Aug 2004 03:38:17 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BzvAX-0005uZ-2q
	for nfs@lists.sourceforge.net; Wed, 25 Aug 2004 03:38:17 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:42557)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1Bzv8p-00021d-DU
	for <nfs@lists.sourceforge.net>; Wed, 25 Aug 2004 11:36:31 +0100
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040825100227.GB16483@sgi.com>
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

Greg Banks wrote:
> On Wed, Aug 25, 2004 at 09:40:36AM +0100, Ian Thurlbeck wrote:
> 
>>Server stats since reboot Monday morning.  It is lightly
>>loaded mostly:
>>
>>Server nfs v3:
>>null       getattr    setattr    lookup     access     readlink
>>85912   2% 1626277 46% 12375   0% 135833  3% 1295417 36% 773     0%
>>read       write      create     mkdir      symlink    mknod
>>136099  3% 151569  4% 7899    0% 64      0% 194     0% 0       0%
>>remove     rmdir      rename     link       readdir    readdirplus
>>6270    0% 37      0% 2931    0% 969     0% 266     0% 4893    0%
>>fsstat     fsinfo     pathconf   commit
>>1508    0% 890     0% 0       0% 41205   1%
> 
> 
> Yes, it is lightly loaded.  You said your block size is 8K, so
> the server has seen about 1.18 GB of writes in 3 days, which is
> just over twice RAM size.  How many of these slowdown events
> did you see in that time?

Well, at least 10 per day, probably more.

> Can you run "vmstat 1" and log the result please?

Not sure what you mean. Quick snapshot follows, but I'll leave it
running and watch what happens during an "event".

procs                      memory      swap          io     system 
    cpu
  r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us 
sy wa id
  0  0  12248  43816  25148  70164    1    0   141   203  234   102  2 
2  0 96
  0  0  12248  43804  25148  70168    0    0     0     0  114    82  0 
2  0 98
  0  0  12248  43772  25180  70168    0    0     0   212  154   125  0 
1  0 99
  0  0  12248  43772  25180  70168    0    0     0     0  111    82  0 
1  0 99


> You said you have a 3ware RAID controller.  What is RAID
> configuration, especially RAID level and stripe width?  What options
> did you use to build the ext3 filesystem?

Capacity:	247.04 GB (482505216 blocks)
Write Cache:	In Use
Configuration:	Striped with Parity 64K (RAID 5)
Stripe size:	64K (65536 bytes)

Ext3 options: anyone know what the default is for Fedora Core 1?

Here is output from tune2fs -l:

tune2fs 1.34 (25-Jul-2003)
Filesystem volume name:   /spare
Last mounted on:          <not available>
Filesystem UUID:          5070c833-cdfe-408b-ae12-ee4587e7ffc4
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal filetype needs_recovery 
sparse_super large_file
Default mount options:    (none)
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              30162944
Block count:              60312018
Reserved block count:     3015600
Free blocks:              34369240
Free inodes:              29320077
First block:              0
Block size:               4096
Fragment size:            4096
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         16384
Inode blocks per group:   512
Filesystem created:       Mon May 19 03:28:12 2003
Last mount time:          Mon Aug 23 08:45:09 2004
Last write time:          Mon Aug 23 08:45:09 2004
Mount count:              31
Maximum mount count:      -1
Last checked:             Mon May 19 03:28:12 2003
Check interval:           0 (<none>)
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               128
Journal inode:            8
Default directory hash:   tea
Directory Hash Seed:      e37b261f-2740-4f6c-a970-d4aade2b54be

Ian

> 
>>So that's about 4 writes for every commit.
> 
> 
> Ok, so your clients are doing enough COMMITs.
> 
> 
>>File system export:
>>
>>/export/raid50  @unix(rw,sync,no_wdelay,hide,nocrossmnt,secure,root_squash,
>>no_all_squash,subtree_check,secure_locks,mapping=identity,
>>anonuid=-2,anongid=-2)
> 
> 
> Hmm, no "async". So much for that idea.
> 
> Greg.


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
