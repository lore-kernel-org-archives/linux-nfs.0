From: Greg Banks <gnb@sgi.com>
Subject: Re: Strange delays on NFS server
Date: Wed, 25 Aug 2004 20:02:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040825100227.GB16483@sgi.com>
References: <411CD601.1080308@RedHat.com> <4120AB46.1080606@stams.strath.ac.uk> <20040816131434.GL3510@suse.de> <4120C8D5.3040606@stams.strath.ac.uk> <20040816145435.GQ3510@suse.de> <4124CD95.7020007@stams.strath.ac.uk> <20040820095854.GC23176@suse.de> <412B0EDE.5010206@stams.strath.ac.uk> <20040825020241.GB16037@sgi.com> <412C5084.9050605@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bzubz-0005MD-Ek
	for nfs@lists.sourceforge.net; Wed, 25 Aug 2004 03:02:35 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bzubx-0000d7-GF
	for nfs@lists.sourceforge.net; Wed, 25 Aug 2004 03:02:33 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: <412C5084.9050605@stams.strath.ac.uk>
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

On Wed, Aug 25, 2004 at 09:40:36AM +0100, Ian Thurlbeck wrote:
> Server stats since reboot Monday morning.  It is lightly
> loaded mostly:
> 
> Server nfs v3:
> null       getattr    setattr    lookup     access     readlink
> 85912   2% 1626277 46% 12375   0% 135833  3% 1295417 36% 773     0%
> read       write      create     mkdir      symlink    mknod
> 136099  3% 151569  4% 7899    0% 64      0% 194     0% 0       0%
> remove     rmdir      rename     link       readdir    readdirplus
> 6270    0% 37      0% 2931    0% 969     0% 266     0% 4893    0%
> fsstat     fsinfo     pathconf   commit
> 1508    0% 890     0% 0       0% 41205   1%

Yes, it is lightly loaded.  You said your block size is 8K, so
the server has seen about 1.18 GB of writes in 3 days, which is
just over twice RAM size.  How many of these slowdown events
did you see in that time?

Can you run "vmstat 1" and log the result please?

You said you have a 3ware RAID controller.  What is RAID
configuration, especially RAID level and stripe width?  What options
did you use to build the ext3 filesystem?

> So that's about 4 writes for every commit.

Ok, so your clients are doing enough COMMITs.

> File system export:
> 
> /export/raid50  @unix(rw,sync,no_wdelay,hide,nocrossmnt,secure,root_squash,
> no_all_squash,subtree_check,secure_locks,mapping=identity,
> anonuid=-2,anongid=-2)

Hmm, no "async". So much for that idea.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
