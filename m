From: Jake Gold <jake@dtiserv2.com>
Subject: Re: NFSv4 and client caching to local disk?
Date: Mon, 31 Mar 2003 16:03:24 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030331160324.43bc1ab4.jake@dtiserv2.com>
References: <6440EA1A6AA1D5118C6900902745938E07D55481@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail01.dtiserv2.com ([216.101.214.6])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1909GS-00088Z-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 16:04:32 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D55481@black.eng.netapp.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Mon, 31 Mar 2003 13:50:52 -0800
"Lever, Charles" <Charles.Lever@netapp.com> wrote:

> > I am also extremely interested in something like this.
> 
> caching large files on local disk is one of the few
> reasonable uses for a disk-based NFS client cache.

> the NFS protocol specifies certain rules for when attribute
> cache entries expire, so this kind of control over your client's
> cache isn't possible without breaking the NFS protocol.
>

You're right, of course, I was just copying feature-for-feature from the Zeus Web server tunables page.

> 
> have you determined why the filer is "overworked?"  which
> version of NFS client do you use?  which protocol (TCP/UDP)?
> if UDP, have you looked for signs of IP fragmentation?
> 
> the best thing you can do for now is make sure the bandwidth
> between your filer and clients is at its maximum.

Well..this is certainly something I'm looking at ...In fact..I have huge (length wise) trouble ticket with NetApp on this issue that has
all of my configuration information in it...(#481133 if you are able to check it :)

This is a DS14 on a FAS940...I'm getting, what I think, is pretty poor performance...
And the obvious problem is disk utilization...which..even if I do have an actual configuration problem, I would really like to minimize filer
disk activity in the future (client disk caching).

I switched to TCP 32k (w|r)size from UDP..I've tried 8k, 16k, 32k buffer sizes..(I modified options nfs.(tcp|udp).xfersize accordingly...)....nothing effected disk utilization significantly.

Mount options: rw,noatime,fg,nfsvers=3,rsize=32768,wsize=32768,hard,intr,nolock,nocto,timeo=600,actimeo=5,tcp,addr=10.8.1.21

I'm using jumbo frames (at 8998 MTU with the e1000 driver on a stock (trimmed) 2.4.20 from kernel.org)...Redhat 7.3 base system.

AMS01NAS001> sysstat -u 1
 CPU   Total    Net kB/s    Disk kB/s    Tape kB/s Cache Cache  CP  CP Disk
       ops/s    in   out   read  write  read write   age   hit time ty util
 30%    2251   556 45735  42042      0     0     0    48s  94%   0%  - 100%
 30%    2008   557 45496  43080      0     0     0    48s  94%   0%  - 100%
 30%    2087   553 45542  42876      0     0     0    48s  94%   0%  - 100%
 28%    1879   524 45562  40680      0     0     0    48s  94%   0%  - 100%
 29%    2030   532 43986  41652      0     0     0    48s  94%   0%  - 100%
 30%    2093   530 45739  42320      0     0     0    48s  94%   0%  - 100%
 30%    2023   560 45544  43024      0     0     0    48s  94%  50%  T 100%
 30%    2114   545 45768  42940      8     0     0    48s  94% 100%  : 100%
 30%    1870   542 46671  42516      0     0     0    48s  94% 100%  : 100%
 31%    2131   536 45723  44172      0     0     0    48s  94% 100%  : 100%
 30%    1960   544 46833  43664      0     0     0    48s  94% 100%  : 100%
 31%    2140   559 47989  44004      0     0     0    48s  94% 100%  : 100%
 31%    2094   565 46966  43472      0     0     0    48s  94% 100%  : 100%
 31%    2070   555 47402  44596      0     0     0    48s  94% 100%  : 100%
 29%    2027   543 45051  41424      0     0     0    48s  94% 100%  : 100%
 27%    1817   523 44423  39748      0     0     0    48s  94% 100%  : 100%
 30%    2129   525 44410  42532    372     0     0    48s  94%  70%  : 100%
 30%    2114   547 45015  42136      0     0     0    48s  94%   0%  - 100%
 29%    1962   528 44107  41144      0     0     0    48s  94%   0%  - 100%

AMS01NAS001> nfsstat -l
10.8.2.1       	<hostname unknown>            	
10.8.2.11      	<hostname unknown>            	NFSOPS =    7298114 ( 7%)
10.8.2.12      	<hostname unknown>            	NFSOPS =    7638814 ( 8%)
10.8.2.13      	<hostname unknown>            	NFSOPS =    7743632 ( 8%)
10.8.2.15      	<hostname unknown>            	NFSOPS =    7509558 ( 8%)
10.8.2.16      	<hostname unknown>            	NFSOPS =    7473626 ( 7%)
10.8.2.17      	<hostname unknown>            	NFSOPS =    7497070 ( 8%)
10.8.2.21      	<hostname unknown>            	NFSOPS =    7586200 ( 8%)
10.8.2.22      	<hostname unknown>            	NFSOPS =    7780060 ( 8%)
10.8.2.23      	<hostname unknown>            	NFSOPS =    7920911 ( 8%)
10.8.2.24      	<hostname unknown>            	NFSOPS =    7959184 ( 8%)
10.8.2.25      	<hostname unknown>            	NFSOPS =    7643417 ( 8%)
10.8.2.26      	<hostname unknown>            	NFSOPS =    7984915 ( 8%)
10.8.2.30      	<hostname unknown>            	NFSOPS =    7479921 ( 7%)


NFSv2 information removed manually:

AMS01NAS001> nfsstat -t

Server rpc:
TCP:
calls      badcalls   nullrecv   badlen     xdrcall    
100037183  0          0          0          0          

UDP:
calls      badcalls   nullrecv   badlen     xdrcall    
0          0          0          0          0          

Server nfs:
calls      badcalls
100037038  0          

Server nfs V3: (100037038 calls)
null       getattr    setattr    lookup     access     readlink   read       
0 0%       20691796 21%0 0%       178967 0%  40195 0%   148 0%     79124715 79%
write      create     mkdir      symlink    mknod      remove     rmdir      
0 0%       0 0%       0 0%       0 0%       0 0%       0 0%       0 0%       
rename     link       readdir    readdir+   fsstat     fsinfo     pathconf   
0 0%       0 0%       425 0%     0 0%       396 0%     396 0%     0 0%       
commit     
0 0%       

Read request stats (version 3)
0-511      512-1023   1K-2047    2K-4095    4K-8191    8K-16383   16K-32767  32K-65535  64K-131071 
0          0          0          0          1363016    749726     1023688    75988430   0          
Write request stats (version 3)
0-511      512-1023   1K-2047    2K-4095    4K-8191    8K-16383   16K-32767  32K-65535  64K-131071 
0          0          0          0          0          0          0          0          0          



Any help you can provide would be very appreciated.

Thanks,
Jake


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
