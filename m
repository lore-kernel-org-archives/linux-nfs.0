From: Greg Banks <gnb@sgi.com>
Subject: Re: Strange delays on NFS server (with piccies)
Date: Fri, 27 Aug 2004 14:10:01 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040827041001.GD19743@sgi.com>
References: <4119FB15.7010205@stams.strath.ac.uk> <411A17F2.2060203@RedHat.com> <411A448D.3080205@stams.strath.ac.uk> <20040811164135.GA11101@suse.de> <411B8987.1030609@stams.strath.ac.uk> <411CD601.1080308@RedHat.com> <4120AB46.1080606@stams.strath.ac.uk> <16683.8588.18082.190876@cse.unsw.edu.au> <412DC316.6080709@stams.strath.ac.uk> <16686.36060.57143.407464@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Thurlbeck <ian@stams.strath.ac.uk>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0Y45-0000em-3o
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 21:10:13 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C0Y44-00066e-Mx
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 21:10:13 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16686.36060.57143.407464@cse.unsw.edu.au>
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

On Fri, Aug 27, 2004 at 11:22:36AM +1000, Neil Brown wrote:
> On Thursday August 26, ian@stams.strath.ac.uk wrote:
> > 
> > Neil, and others
> > 
> > I've gathered some useful data (I hope) on the problem. I ran a variant 
> > of Neil's script for 2.4 kernel for most of a day (9.30-15.00).
> 
> Can you get some process listings that correlate with the sudden drop
> in "free" shown by vmstat and see what is happening?

Looking at the "vmstat.log" file....

procs                      memory      swap          io     system         cpu
 r  b   swpd   free   buff  cache   si   so    bi    bo   in    cs us sy wa id
 1  0  12284  65232  12344  86876    0    0     0   124  142   144  1  0  0 99
 0  0  12284  65228  12344  86880    0    0     4     0  127    99  0  1  0 99
 0  0  12284  65228  12344  86880    0    0     0     0  136   100  1  0  0 99
 0  0  12284  65188  12384  86884    0    0     4   192  293   475  1  1  0 98
 0  0  12284  65184  12384  86884    0    0     0     0  212   311  0  2  0 98
 0  0  12284  65176  12384  86892    0    0     0     8  152   118  1  0  0 99

Machine is basically idle, with occasional writes to disk (bo) and
no reads from disk (bi) and basically no userspace CPU activity (us).
Memory parameters are stable.  This is probably just your NFS traffic.

 0  1  12284  60104  12412  91932    0    0  2664    92  207   267  3  2  0 95
 1  5  12284  36192  12460 115552  112    0 11996  5208  427   578 11 14  0 75
 0  5  12284  27728  12516 124060   32    0  4356  2540  307   271  5  5  0 90
 1  4  12284   4500   9416 150500   76    0 27600  2140  678  1015 25 36  0 39
 1  5  12284   4480   9288 150136    8    0  2020  2304  288   252  4  4  0 92
 0  8  12284   4432   9372 149860    0    0 11016  3088  435   883 17 13  0 70
 0  9  12284   4816   8232 150472    0    0 26680  1240  711  1051 36 25  0 39
 0  9  12284   5368   8272 149796    0    0  7552  1412  326   342  9 10  0 81
 3  9  12284   4880   8148 150296    0    0  6916  2080  305   300  9 10  0 81
 1 10  12284   3256   8164 151856    0    0 14084  3244  415   521 17 16  0 67
 5 18  12284   3140   8168 151956    0    0  3672  4536  517   406  2  3  0 94

Suddenly there's lots of userspace CPU activity, a lot of write to disk,
and *lot* more read from disk, which is filling the page cache "cache"
with pages storing the new data read in; these pages are being taken from
the  "free" and "buff" states.  The reads are what I suspected when I saw
the difference in "cached" in the two "top" samples Ian posted originally.
The userspace activity means its some kind of user program, and probably
not (or not entirely) a kernelside side effect of write traffic.

So my conclusion is that this has little to do with NFS, and you've got
some kind of mostly diskbound (so it won't be obvious in "top") userspace
program doing lots and lots of writes and some more reads.  Something
doing a big grep and saving the results to disk perhaps?  If Linux had
an equivalent of IRIX' topio program it would be trivial to find the
culprit.

IOW, this is exactly what someone suggested much earlier in the
thread, and not an NFS problem.

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
