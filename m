From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Re: Strange delays on NFS server
Date: Wed, 25 Aug 2004 09:40:36 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412C5084.9050605@stams.strath.ac.uk>
References: <20040811164135.GA11101@suse.de> <411B8987.1030609@stams.strath.ac.uk> <411CD601.1080308@RedHat.com> <4120AB46.1080606@stams.strath.ac.uk> <20040816131434.GL3510@suse.de> <4120C8D5.3040606@stams.strath.ac.uk> <20040816145435.GQ3510@suse.de> <4124CD95.7020007@stams.strath.ac.uk> <20040820095854.GC23176@suse.de> <412B0EDE.5010206@stams.strath.ac.uk> <20040825020241.GB16037@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Olaf Kirch <okir@suse.de>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BztKp-0006di-K2
	for nfs@lists.sourceforge.net; Wed, 25 Aug 2004 01:40:47 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BztKn-0000MI-Uw
	for nfs@lists.sourceforge.net; Wed, 25 Aug 2004 01:40:47 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:42213)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1BztKe-0004GZ-Da
	for <nfs@lists.sourceforge.net>; Wed, 25 Aug 2004 09:40:36 +0100
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20040825020241.GB16037@sgi.com>
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
> On Tue, Aug 24, 2004 at 10:48:14AM +0100, Ian Thurlbeck wrote:
> 
>>What on earth could be writing up to 3GB of data to the drive ?
>>As before the usual suspects of kjournald, kupdated, bdflush and
>>nfsd turn up on the process list.
>>
>>Just how big is the nfs write cache on a typical server ?
> 
> 
> It can be most of RAM.
> 
> 
>>Is it
>>writing the whole lot one go ?
> 
> 
> It might be.  What ratio of COMMIT to WRITE calls are you
> seeing in nfsstat?  Does the export have "sync" or "async"
> in its options?
> 
> Greg.

Greg

Server stats since reboot Monday morning.  It is lightly
loaded mostly:

Server nfs v3:
null       getattr    setattr    lookup     access     readlink
85912   2% 1626277 46% 12375   0% 135833  3% 1295417 36% 773     0%
read       write      create     mkdir      symlink    mknod
136099  3% 151569  4% 7899    0% 64      0% 194     0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
6270    0% 37      0% 2931    0% 969     0% 266     0% 4893    0%
fsstat     fsinfo     pathconf   commit
1508    0% 890     0% 0       0% 41205   1%

So that's about 4 writes for every commit.

File system export:

/export/raid50  @unix(rw,sync,no_wdelay,hide,nocrossmnt,secure,root_squash,
no_all_squash,subtree_check,secure_locks,mapping=identity,
anonuid=-2,anongid=-2)

I've got Neil's script running to correlate disk writes with
nfs ops and these slowdown event times.  I'll post the results
in a day or so.

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
