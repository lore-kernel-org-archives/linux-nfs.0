From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Re: Strange delays on NFS server
Date: Tue, 24 Aug 2004 15:22:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <412B4F27.8060401@stams.strath.ac.uk>
References: <4119FB15.7010205@stams.strath.ac.uk>	<411A17F2.2060203@RedHat.com>	<411A448D.3080205@stams.strath.ac.uk>	<20040811164135.GA11101@suse.de>	<411B8987.1030609@stams.strath.ac.uk>	<411CD601.1080308@RedHat.com>	<4120AB46.1080606@stams.strath.ac.uk> <16683.8588.18082.190876@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzcCB-0000rS-E5
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 07:22:43 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BzcCA-0002Rq-Np
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 07:22:43 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:41722)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1BzcBz-0000wj-W2
	for <nfs@lists.sourceforge.net>; Tue, 24 Aug 2004 15:22:31 +0100
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
>>Would changing some of the bdflush settings help at all?
> 
> 
> Maybe.  I would start with
>   echo 200 > /proc/sys/vm/dirty_expire_centisecs

> You said you are using ext3.  Are you using journal=data or the
> default journal=ordered ??

I'm using the default on Fedora 1, ordered data.

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

I'm using FC1 which has 2.4.22 as its base.  I think the 
/proc/sys/vm/dirty_expire_centisecs and the above scriptlet are
for 2.6 only.  The nfs stats work, but the /proc/diskstats file
is missing.

Do you have any suggestions for /proc/sys/vm/bdflush instead ? Here
are the current settings:

30      500     0       0       500     3000    60      20      0

> It would also be interesting to see if there was a pattern in the
> timing, particular how long the interval was between one pause and the
> next.  

I'll start keeping a note of the time of these events.

> Also getting these sets of number for different numbers of nfsd
> threads could turn your subjective impression into objective data.
> 
> NeilBrown

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
