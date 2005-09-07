From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: Some code, and a question
Date: Wed, 07 Sep 2005 07:37:01 -0700
Message-ID: <1126103821.16701.8.camel@seki.nac.uci.edu>
References: <1126046397.3000.188.camel@seki.nac.uci.edu>
	 <20050907010219.GA14233@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: strombrg@dcs.nac.uci.edu, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ED13Q-0000Y2-RS
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 07:37:36 -0700
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ED13P-0001BP-KA
	for nfs@lists.sourceforge.net; Wed, 07 Sep 2005 07:37:36 -0700
To: Greg Banks <gnb@sgi.com>
In-Reply-To: <20050907010219.GA14233@sgi.com>
Sender: nfs-admin@lists.sourceforge.net
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

On Wed, 2005-09-07 at 11:02 +1000, Greg Banks wrote: 
> On Tue, Sep 06, 2005 at 03:39:57PM -0700, Dan Stromberg wrote:
> > 
> > OK, I know NFS isn't usually thought of as the fastest protocol under
> > the sun,
> 
> Why would you think that?  NFSv3 can be very efficient at moving
> bits from point A to point B.

You mean aside from the troublesome back-and-forthing on a high latency
network?

Perhaps this'll be less of an issue when NFS becomes extent-based.

> > My question is, before diving into trying to determine this empirically,
> > is there any theoretical reason why it would be better to have
> > rsize==wsize,
> 
> From a protocol point of view, no.

That much is interesting.  Thank you.

I'm also thinking about resource contention on the wire...

> > or should it be better to just pick whatever rsize gives
> > the best read performance and pick whatever wsize gives the best write
> > performance, and not worry about if rsize!=wsize?
> 
> It will depend on the workload, but generally read and write throughput
> will be better the larger the block size, up to a value beyond the
> Linux kernel's ability to support.  I expect you will find your optimum
> at rsize=wsize=32K.

Here's the summary output from my script.  You may find it surprising.
It may have bugs, but so far it seems to be coming up with results that
one might not expect.  This was iterating rsize's and wsize's from 4K to
64K in steps of 1K.  BTW, this is from an AIX 5.1 host to a Solaris 9
host, but the script should run on nearly any unix or linux:

======> Writing in isolation (read protocol!=write protocol, read version!=write version, rsize!=wsize)
Creating 5 pipes
popening echo Number of measurements: $(wc -l)
popening echo Average number of seconds: $(cut -d " " -f 4 | avg -i)
popening echo Average time: $(cut -d " " -f 4 | avg -i | modtime -i)
popening sleep 1; echo Best time: $(cut -d " " -f 4 | highest -s $(expr 1024 \* 1024) -r -n 1 | modtime)
popening sleep 2; echo Best numbers:; highest -s $(expr 1024 \* 1024) -r -f 2 -n 5
Number of measurements: 26
Average number of seconds: 703.932692308
Average time: 11 minutes 43 seconds
Best time: 9 minutes 43 seconds
Best numbers:
xfer-result-Writing-16384-3-udp:Write time:  583.82
xfer-result-Writing-8192-3-tcp:Write time:  638.06
xfer-result-Writing-9216-3-tcp:Write time:  649.62
xfer-result-Writing-16384-3-tcp:Write time:  653.30
xfer-result-Writing-13312-3-tcp:Write time:  654.96

======> Reading in isolation (read protocol!=write protocol, read version!=write version, rsize!=wsize)
Creating 5 pipes
popening echo Number of measurements: $(wc -l)
popening echo Average number of seconds: $(cut -d " " -f 4 | avg -i)
popening echo Average time: $(cut -d " " -f 4 | avg -i | modtime -i)
popening sleep 1; echo Best time: $(cut -d " " -f 4 | highest -s $(expr 1024 \* 1024) -r -n 1 | modtime)
popening sleep 2; echo Best numbers:; highest -s $(expr 1024 \* 1024) -r -f 2 -n 5
Number of measurements: 25
Average number of seconds: 389.25
Average time: 6 minutes 29 seconds
Best time: 4 minutes 18 seconds
Best numbers:
xfer-result-Reading-16384-3-tcp:Read time:  258.31
xfer-result-Reading-8192-3-tcp:Read time:  337.19
xfer-result-Reading-9216-3-tcp:Read time:  339.16
xfer-result-Reading-10240-3-tcp:Read time:  340.15
xfer-result-Reading-12288-3-tcp:Read time:  340.26

======> Best composite of read and write (read protocol==write protocol, read version==write version, rsize!=wsize)
tcp 3 rsize: 4096 readtime: 485.49 wsize: 8192 writetime: 638.06 composite: 714.345
tcp 3 rsize: 5120 readtime: 471.15 wsize: 8192 writetime: 638.06 composite: 721.515
tcp 3 rsize: 6144 readtime: 471.14 wsize: 8192 writetime: 638.06 composite: 721.520
tcp 3 rsize: 7168 readtime: 469.20 wsize: 8192 writetime: 638.06 composite: 722.490
tcp 3 rsize: 4096 readtime: 485.49 wsize: 9216 writetime: 649.62 composite: 731.685
/\/\/\
udp 3 rsize: 5120 readtime: 514.31 wsize: 16384 writetime: 583.82 composite: 618.575
udp 3 rsize: 7168 readtime: 481.18 wsize: 16384 writetime: 583.82 composite: 635.140
udp 3 rsize: 4096 readtime: 473.37 wsize: 16384 writetime: 583.82 composite: 639.045
udp 3 rsize: 6144 readtime: 466.38 wsize: 16384 writetime: 583.82 composite: 642.540
udp 3 rsize: 9216 readtime: 405.25 wsize: 16384 writetime: 583.82 composite: 673.105
/\/\/\

======> Best composite of read and write (read protocol==write protocol, read version==write version, rsize==wsize)
tcp 3 8192 both sizes: 8192 readtime: 337.19 writetime: 638.06 composite: 788.495
udp 3 9216 both sizes: 9216 readtime: 405.25 writetime: 664.46 composite: 794.065
tcp 3 9216 both sizes: 9216 readtime: 339.16 writetime: 649.62 composite: 804.850
tcp 3 13312 both sizes: 13312 readtime: 341.15 writetime: 654.96 composite: 811.865
tcp 3 14336 both sizes: 14336 readtime: 372.20 writetime: 665.83 composite: 812.645

Comments would be very welcome.

It almost seems like we might be able to improve performance by mounting the same filesystem three times onto a given system:
1) In a way that will optimize reads
2) In a way that will optimize writes
3) In a way that will optimize writing and then reading immediately afterward

Thanks!




-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
