From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: NFS tuning - high performance throughput.
Date: Wed, 15 Jun 2005 08:03:52 -0500
Message-ID: <EXCHG2003LVbNDN4Cxp000005b6@EXCHG2003.microtech-ks.com>
References: <42AF5F0A.3080601@sohovfx.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiXXJ-0002m4-B4
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 06:02:29 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DiXXH-00041L-LP
	for nfs@lists.sourceforge.net; Wed, 15 Jun 2005 06:02:29 -0700
To: "'M. Todd Smith'" <todd@sohovfx.com>, <nfs@lists.sourceforge.net>
In-Reply-To: <42AF5F0A.3080601@sohovfx.com>
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


Are you using the same dd test on the local machine test?  If so
cache will be a major factor.

Also, raid5 stripe size, bigger is almost always better, I would
do some testing with different strip sizes and see how it affects
the speed, I have never seen less than 32k be faster than 32k.

Are you using md for the raid5 setup or something else that has
not been mentioned?

                     Roger 

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of M. Todd Smith
> Sent: Tuesday, June 14, 2005 5:50 PM
> To: nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS tuning - high performance throughput.
> 
> First off thanks for the overwhelming response.  I'll start 
> with Bill's response, fill in any holes after that.
> 
> Bill Rugolsky Jr. wrote:
> 
> >I assume that you mean 45 MiB/s?  Reading or writing?  What are you 
> >using for testing?  What are the file sizes?
> >  
> >
> I'm not sure what a MiB/s is.  I've been using the following 
> for testing writes.
> 
> time dd if=/dev/zero of=/mnt/array1/testfile5G.001 bs=512k count=10240
> 
> which writes a 5Gb file to the mounted NFS volume, I've then 
> been taking the times thrown back once that finishes and 
> calculating the megabytes/second, and averaging over ten 
> seperate tests unmounting and remounting the volume after each test.
> 
> For reads I cat the file back to /dev/null
> 
> time cat /mnt/array1/testfile5G.001 >> /dev/null
> 
> Read times are better, but not optimal either usually sitting 
> around ~ 70Mbytes/sec.
> 
> > 
> >Have you validated network throughput using ttcp or netperf?
> >  
> >
> We did at one point validate newtork throughput with ttcp, 
> although I have yet to find a definite guide to using ttcp, 
> here is some output.
> 
> sender:
> ttcp-t: buflen=8192, nbuf=2048, align=16384/0, port=5001
> ttcp-t: sockbufsize=65535,  # udp -> test_sweet #
> ttcp-t: 16777216 bytes in 0.141 real seconds = 116351.241 KB/sec +++
> ttcp-t: 2054 I/O calls, msec/call = 0.070, calls/sec = 14586.514
> ttcp-t: 0.000user 0.050sys 0:00real 35% 0i+0d 0maxrss 0+2pf 0+0csw
> 
> receiver:
> ttcp-r: buflen=8192, nbuf=2048, align=16384/0, port=5001
> ttcp-r: sockbufsize=65536,  # udp #
> ttcp-r: 16777216 bytes in 0.141 real seconds = 115970.752 KB/sec +++
> ttcp-r: 2050 I/O calls, msec/call = 0.071, calls/sec = 14510.501
> ttcp-r: 0.000user 0.059sys 0:00real 35% 0i+0d 0maxrss 0+1pf 2017+18csw
> 
> >You say that you've read the tuning guides, but you haven't told us 
> >what you have touched.  Please tell us:
> >
> >   o client-side NFS mount options
> >  
> >
> exec,dev,suid,rw,rsize=32768,wsize=32768,timeo=500,retrans=10,
> retry=60,bg
> 1 0
> 
> >   o RAID configuration (level, stripe size, etc.)
> >  
> >
> 
> RAID 5, 4k strip size, XFS file system.
> 
> meta-data=/array1               isize=256    agcount=32, 
> agsize=13302572 
> blks
>                    =                      sectsz=512 
> data             =                      bsize=4096   
> blocks=425682304, 
> imaxpct=25
>                     =                     sunit=0      swidth=0 blks, 
> unwritten=1
> naming        =version 2       bsize=4096 
> log               =internal         bsize=4096   
> blocks=32768, version=1
>                     =                     sectsz=512   sunit=0 blks
> realtime        =none             extsz=65536  blocks=0, rtextents=0
> 
> >   o I/O scheduler
> >  
> >
> Not sure what you mean here.
> 
> >   o queue depths (/sys/block/*/queue/nr_requests)
> >  
> >
> 1024
> 
> >   o readahead (/sbin/blockdev --getra <device>)
> >  
> >
> 256
> 
> >   o mount options (e.g., are you using noatime)
> >  
> >
> /array1                 xfs     logbufs=8,noatime,nodiratime
> 
> >   o filesystem type
> >  
> >
> XFS
> 
> >   o journaling mode, if Ext3 or Reiserfs
> >  
> >
> >   o journal size
> >
> >   o internal or external journal
> >  
> >
> log               =internal         bsize=4096   
> blocks=32768, version=1
>                     =                     sectsz=512   sunit=0 blks
> 
> >   o vm tunables:
> >
> >      vm.dirty_writeback_centisecs
> >      vm.dirty_expire_centisecs
> >      vm.dirty_ratio
> >      vm.dirty_background_ratio
> >      vm.nr_pdflush_threads
> >      vm.vfs_cache_pressure
> >  
> >
> vm.vfs_cache_pressure = 100
> vm.nr_pdflush_threads = 2
> vm.dirty_expire_centisecs = 3000
> vm.dirty_writeback_centisecs = 500
> vm.dirty_ratio = 29
> vm.dirty_background_ratio = 7
> 
> The SAN layout is as follows
> 
> I did not set this part up and have had little time to catch 
> up on it so far.  We initially attempted to have this setup 
> such that we would stripe across both arrays but had some 
> problems and due to time constraints on having the new system 
> in place had to go back to the two array method.
> 
> Just went and had a look, I'm not sure it all makes sense to me yet.
> 
> ----------------------
> 2*parity drives
> 2*spare drives
> ----------------------
>        | |      | |           (2 FC conns)
> ----------------------
> ARRAY 1
> ----------------------
>        | |      | |
> ----------------------
> ARRAY 2
> ----------------------
>        | |      | |
> ----------------------
> FC controller card
> -----------------------
>        | |      | |
> -----------------------
> FC card on server
> -----------------------
> 
> Not sure why the connections are chained all the way through 
> the system like that, I'll have to ask our hardware vendor 
> why its setup that way.  
> Theoretically the throughput to/from this SAN should be more 
> in the range of 300-400Mb/s.  Haven't had a chance to do any 
> testing with that though.
> 
> Using 256 NFS threads on the server, and the following sysctl 
> settings.
> net.ipv4.tcp_mem = 196608       262144  393216
> net.ipv4.tcp_wmem = 4096        65536   8388608
> net.ipv4.tcp_rmem = 4096        87380   8388608
> net.core.rmem_default = 65536
> net.core.rmem_max = 8388608
> net.core.wmem_default = 65536
> net.core.wmem_max = 8388608
> 
> Have hyperthreading turned off.
> 
> Also if anyone can recommend some good NFS reference 
> material, I'd love to get my hands on it.
> 
> Cheers
> Todd
> 
> --
> Systems Administrator
> ----------------------------------
> Soho VFX - Visual Effects Studio
> 99 Atlantic Avenue, Suite 303
> Toronto, Ontario, M6K 3J8
> (416) 516-7863
> http://www.sohovfx.com
> ----------------------------------
> 
> 
>  
> 
> 
> 
> -------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux Migration 
> Strategies from IBM. Find simple to follow Roadmaps, 
> straightforward articles, informative Webcasts and more! Get 
> everything you need to get up to speed, fast. 
> http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net 
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
