From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Strange delays on NFS server
Date: Tue, 24 Aug 2004 21:07:56 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16683.8588.18082.190876@cse.unsw.edu.au>
References: <4119FB15.7010205@stams.strath.ac.uk>
	<411A17F2.2060203@RedHat.com>
	<411A448D.3080205@stams.strath.ac.uk>
	<20040811164135.GA11101@suse.de>
	<411B8987.1030609@stams.strath.ac.uk>
	<411CD601.1080308@RedHat.com>
	<4120AB46.1080606@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BzZ9s-00029C-Ft
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 04:08:08 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BzZ9r-0001sV-UA
	for nfs@lists.sourceforge.net; Tue, 24 Aug 2004 04:08:08 -0700
To: Ian Thurlbeck <ian@stams.strath.ac.uk>
In-Reply-To: message from Ian Thurlbeck on Monday August 16
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

On Monday August 16, ian@stams.strath.ac.uk wrote:
> 
> I bumped the nfsd's up to 64 (from 32) and subjectively the problem gets 
> worse.  I then reduced them to 16 and things are a bit better...

Odd.

> 
> Would changing some of the bdflush settings help at all?

Maybe.  I would start with
  echo 200 > /proc/sys/vm/dirty_expire_centisecs

You said you are using ext3.  Are you using journal=data or the
default journal=ordered ??

Also, it would be interesting to compare nfs ops per second against
disk i/os per second over time.
Something like..

  while :
  do
    perl -ne 'if (/^proc3/)  { @a=split ; shift @a; shift @a; print eval(join("+", @a))."  ";}' /proc/net/rpc/nfsd
    perl -ne 'if (/hda /) { @a=split; print $a[9]."\n";}' /proc/diskstats  
    sleep 1
  done | perl -ne '@_=split; print( ($_[0]-$a[0])." ".($_[1]-$a[1])."\n"); @a=@_;'

If the pauses correspond to periods with very low nfs ops/sec and very
high writes per second, then it confirms that it is a disk flushing
problem.

It would also be interesting to see if there was a pattern in the
timing, particular how long the interval was between one pause and the
next.  
Also getting these sets of number for different numbers of nfsd
threads could turn your subjective impression into objective data.

NeilBrown


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
