From: Brett Petrusek <brettp@aspsys.com>
Subject: Re: IA64 Server / IA32 Client problem
Date: Tue, 02 Aug 2005 09:37:57 -0600
Message-ID: <42EF9355.1090703@aspsys.com>
References: <482A3FA0050D21419C269D13989C611308539E55@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dzynb-0006CI-SB
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 08:35:23 -0700
Received: from [216.150.199.16] (helo=mail.aspsys.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Dzyna-0007oY-Cb
	for nfs@lists.sourceforge.net; Tue, 02 Aug 2005 08:35:23 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611308539E55@lavender-fe.eng.netapp.com>
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

Lever, Charles wrote:

>>I'm not sure if this is a bug or what, but I am experiencing severe 
>>performace problems between an IA64 NFS server and IA32 NFS client. I 
>>have tried every combination of socket buffer sizes as well as many 
>>other nfs options, but none of them seem to have any effect. I have 
>>tried RHEL21 to RHEL3U5 with all of these socket combos and still no 
>>difference. The command I am running is:
>>
>>time dd if=/dev/zero of=/scratch_dir_across_nfs bs=1M count=128
>>
>>Between two IA32 machines this takes 4-5 seconds. Between 
>>IA64 server and IA32 client this takes on the order of 
>>minutes. Network performance has been eliminated from the 
>>equation as after kernel tuning we have achieved consistent 
>>94% of peak tcp throughput and 95.7% of peak udp throughput 
>>on our GigE network.  This is both between IA32 and IA64 systems.
>>    
>>
>
>can you tell us about the file system on the ia64 server.  block size,
>fstype, etc?
>
>what's the page size on that system?
>
>have you run local performance tests on the server?
>
>
>-------------------------------------------------------
>SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
>from IBM. Find simple to follow Roadmaps, straightforward articles,
>informative Webcasts and more! Get everything you need to get up to
>speed, fast. http://ads.osdn.com/?ad_idt77&alloc_id492&op=click
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs
>  
>
Here's the info of the two filesystems from dumpe2fs:

On the Itanium:
Filesystem volume name:   /
Last mounted on:          <not available>
Filesystem UUID:          7f29192c-e37d-11d7-9483-d26f707daf6e
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal filetype needs_recovery 
sparse_super large_file
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              3826368
Block count:              7662080
Reserved block count:     383104
Free blocks:              3603448
Free inodes:              3686174
First block:              0
Block size:               4096
Fragment size:            4096
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         16352
Inode blocks per group:   511
Last mount time:          Fri Jul 15 16:55:05 2005
Last write time:          Fri Jul 15 16:55:05 2005
Mount count:              30
Maximum mount count:      -1
Last checked:             Wed Sep 10 04:56:57 2003
Check interval:           0 (<none>)
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               128
Journal UUID:             <none>
Journal inode:            8
Journal device:           0x0000
First orphan inode:       229217

And on the Xeon:
Filesystem volume name:   /
Last mounted on:          <not available>
Filesystem UUID:          49140d68-f52a-11d9-832b-94d6e9be8214
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal filetype needs_recovery 
sparse_super large_file
Filesystem state:         clean
Errors behavior:          Continue
Filesystem OS type:       Linux
Inode count:              4627616
Block count:              9247415
Reserved block count:     462370
Free blocks:              6511674
Free inodes:              4466407
First block:              0
Block size:               4096
Fragment size:            4096
Blocks per group:         32768
Fragments per group:      32768
Inodes per group:         16352
Inode blocks per group:   511
Last mount time:          Tue Aug  2 08:06:18 2005
Last write time:          Tue Aug  2 08:06:18 2005
Mount count:              1
Maximum mount count:      -1
Last checked:             Tue Aug  2 08:06:10 2005
Check interval:           0 (<none>)
Reserved blocks uid:      0 (user root)
Reserved blocks gid:      0 (group root)
First inode:              11
Inode size:               128
Journal UUID:             <none>
Journal inode:            8
Journal device:           0x0000
First orphan inode:       0

Unfortunately, this is not a performance issue (except with NFS of 
course), as we can achieve peak throughput between two machines with 
identical architecture. Both these machines are, however, using the 2.4 
kernel currently, but tests have been performed with 2.6 as well with no 
difference.
My understanding of NFS (correct me if I am wrong) is that it converts 
the data representation to a format called XDR, which is then transfered 
over the wire to the client/server who translates XDR into the 
representation of the local filesystem. My gut instinct tells me that 
something is being lost in translation.

Brett P


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
