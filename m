From: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Subject: Re: Tracing down 250ms open/chdir calls
Date: Mon, 16 Feb 2009 14:44:13 +0100
Message-ID: <49996DAD.3000508@aei.mpg.de>
References: <49991BE7.1090104@aei.mpg.de> <499968F0.8000509@scalableinformatics.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: beowulf@beowulf.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: landman@scalableinformatics.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757873AbZBPNos@vger.kernel.org>
In-Reply-To: <499968F0.8000509@scalableinformatics.com>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Joe, 

(keeping all lists cross-posted, please shout briefly at me if I fall
off the line of not being rude):

Joe Landman schrieb:
> 
>   Are you using a "standard" cluster scheduler (SGE, PBS, ...) or a
> locally written one?
> 

We use Condor (http://www.cs.wisc.edu/condor/).
> 
> Hmmm...  These are your head nodes?  Not your NFS server nodes?  Sounds
> like there are a large number of blocked IO processes ... try a
> 

Yes, these are the head nodes and not the NFS servers.

>     vmstat 1
> 
> and look at the "b" column (usually second from left ... or nearly
> there).  Lots of blocked IO processes can have the affect of introducing
> significant latency into all system calls.
> 

Right now, (system load 40, but still quite responsive box):

vmstat 1
procs -----------memory---------- ---swap-- -----io---- -system-- ----cpu----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa
 1  0     60 1748932  49204 7181132    0    0   393   730   15   12  8  4 76 12
 1  0     60 1738804  49204 7187768    0    0     0   254 3340 11635 15  8 77  0
 1  0     60 1693220  49216 7193328    0    0     0   306 3118 9296 16  7 77  0
 1  0     60 1751184  49224 7192924    0    0     0   343 3450 10866 12  9 79  0
 0  0     60 1754924  49224 7192936    0    0     0   127 2744 6750  5  7 87  2
 0  0     60 1756932  49240 7187552    0    0     0   532 3289 9673  3  6 91  0
 0  0     60 1752664  49240 7193776    0    0     0    77 2835 10075  2  7 92  0
 2  0     60 1754956  49244 7193820    0    0     0   553 3976 14870  4 12 84  0
 1  0     60 1742032  49252 7206288    0    0     0   193 3588 9133  5  6 89  0
 1  0     60 1736920  49252 7206316    0    0     0   284 3821 9402  7  7 86  0
 4  0     60 1742292  49260 7193964    0    0     0   514 4545 12428 17 10 74  0

> Hmmm.... What happens if you make these local to each box?  What are the
> mount options for the mount points?  We have spoken to other users with
> performance problems on such servers.  The NFS server/OS combination you
> indicate above isn't known to be very fast.  This isn't your problem
> (see later), but it looks like your own data suggests you are giving up
> nearly an order of magnitude performance using this NFS server/OS
> combination, likely at a premium price as well.
> 

The mount options are pretty standard NFSv3 via tcp, ...:

s02:/atlashome/USER on /home/USER type nfs (rw,vers=3,rsize=32768,wsize=32768,namlen=255,soft,nointr,nolock,noacl,proto=tcp,
timeo=600,retrans=2,sec=sys,mountaddr=10.20.20.2,mountvers=3,mountproto=tcp,addr=10.20.20.2)

> Assuming you aren't using mount options of noac,sync,...  Could you
> enlighten us as to what mount options are for the head nodes?
The linux data server are exporting NFS with async, the X4500 should be about the same,
i.e. we set nocacheflushing for the zpool

> 
> Also, the way the code is written, you are doing quite a few calls to
> gettimeofday ... you could probably avoid this with a little re-writing
> of the main loop.
> 

Well, that proofs that I should never be let near any serious programming - 
at least not in time critical parts of the codes ;)

> If you are using noac or sync on your NFS mounts, then this could
> explain some of the differences you are seeing (certainly the 100/s vs
> 800/s ... but not likely the 4/s)
> 
> However, if you notice that h2 in your table is an apparent outlier,
> there may be something more systematic going on there.  Since you
> indicate there is a high load going on while you are testing, this is
> likely what you need to explore.
> 

That was my idea as well.

> Grab the atop program.  It is pretty good about letting you explore what
> is causing load.  That is, despite your x4500's/Solaris combo showing
> itself not to be a fast NFS server the problem appears to be more likely
> more localized on the h2 machine than on the NFS machines.
> 
> http://freshmeat.net/projects/atop/

I'll try that and will dive again into iotop as well.

Cheers

Carsten
