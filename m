From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Re: Strange delays on NFS server (with piccies)
Date: Thu, 26 Aug 2004 12:01:42 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412DC316.6080709@stams.strath.ac.uk>
References: <4119FB15.7010205@stams.strath.ac.uk>	<411A17F2.2060203@RedHat.com>	<411A448D.3080205@stams.strath.ac.uk>	<20040811164135.GA11101@suse.de>	<411B8987.1030609@stams.strath.ac.uk>	<411CD601.1080308@RedHat.com>	<4120AB46.1080606@stams.strath.ac.uk> <16683.8588.18082.190876@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0I1F-0005oH-PA
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 04:02:13 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1C0I1D-0004AL-6B
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 04:02:13 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:43423)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1C0I0k-0002KA-FM
	for <nfs@lists.sourceforge.net>; Thu, 26 Aug 2004 12:01:42 +0100
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16683.8588.18082.190876@cse.unsw.edu.au>
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

Neil Brown wrote:
> On Monday August 16, ian@stams.strath.ac.uk wrote:
> 
>>I bumped the nfsd's up to 64 (from 32) and subjectively the problem gets 
>>worse.  I then reduced them to 16 and things are a bit better...
> 
> 
> Odd.
> 
> 
>>Would changing some of the bdflush settings help at all?
> 
> 
> Maybe.  I would start with
>   echo 200 > /proc/sys/vm/dirty_expire_centisecs
> 
> You said you are using ext3.  Are you using journal=data or the
> default journal=ordered ??
> 
> Also, it would be interesting to compare nfs ops per second against
> disk i/os per second over time.
> Something like..
> 
>   while :
>   do
>     perl -ne 'if (/^proc3/)  { @a=split ; shift @a; shift @a; print eval(join("+", @a))."  ";}' /proc/net/rpc/nfsd
>     perl -ne 'if (/hda /) { @a=split; print $a[9]."\n";}' /proc/diskstats  
>     sleep 1
>   done | perl -ne '@_=split; print( ($_[0]-$a[0])." ".($_[1]-$a[1])."\n"); @a=@_;'
> 
> If the pauses correspond to periods with very low nfs ops/sec and very
> high writes per second, then it confirms that it is a disk flushing
> problem.
> 
> It would also be interesting to see if there was a pattern in the
> timing, particular how long the interval was between one pause and the
> next.  
> Also getting these sets of number for different numbers of nfsd
> threads could turn your subjective impression into objective data.
> 
> NeilBrown

Neil, and others

I've gathered some useful data (I hope) on the problem. I ran a variant 
of Neil's script for 2.4 kernel for most of a day (9.30-15.00).

It's all here:

http://www.stams.strath.ac.uk/~ian/nfs/

Files:
data.all.raw	raw data, 3 columns: HH:MM:SS nfsops diskwrites
data.all.plot	massaged data, 3 columns: SECONDS nfsops diskwrites
data.all.eps	postscript plot of massaged data
data.all.gif	gif plot of massaged data

(The massaged data has had missing data filled in. Sometimes the
seconds field jumps 2 seconds. HH:MM:SS changed to seconds from start)

I think this shows no correlation between NFS ops and disk writes
with respect to these big slowdowns (the big peaks in lower graph, there
are 5). Something with a periodicity of 600 seconds is also writing to
the disk. (This was done with 32 nfsd threads, BTW)

There is another similar set of files zooming in on the first 2
events (data.zoom.*). You can see from this graph that in the disk 
writing event lasts about 50 seconds, and the client machines hang on 
NFS ops for this period (pretty annoying, I can tell you!).

Also in the directory is the output of "vmstat 1" showing one of these
events (vmstat.log).

Can anyone deduce anything from this?

Many thanks

Ian

PS: How big are these "wsect" counts in /proc/partitions in terms of bytes ?

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
