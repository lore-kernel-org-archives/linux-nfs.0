From: James Pearson <james-p@moving-picture.com>
Subject: Re: df and "Value too large for defined data type"
Date: Wed, 25 Feb 2004 22:30:47 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403D2217.9040405@moving-picture.com>
References: <403B512C.66BF37BB@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw7ZF-0006KE-Vv
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 14:31:49 -0800
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw7Xm-000269-T6
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 14:30:19 -0800
To: nfs@lists.sourceforge.net
In-Reply-To: <403B512C.66BF37BB@moving-picture.com>
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

I think I've found part of the reason for this - and it's not an NFS 
problem - the 'Value too large for defined data type' comes from the 
'return -EOVERFLOW' from vfs_statfs_native() in fs/open.c - the value of 
f_files (total number of nodes in file system) returned by FSSTAT from 
the server is 2^64 - 1 (18446744073709551615) !!

It looks like 2.4.X doesn't check for this overflow - and just takes the 
  lower 32 bits.

The underlying remote file system is XFS - which in this case appears to 
be saying that it has 2^64 - 1 inodes - which doesn't seem correct...

James Pearson

James Pearson wrote:
> Using a (vanilla) 2.6.3 NFS client and using df on a on a particular NFS
> mounted file system gives:
> 
> df: `/mnt/tmp': Value too large for defined data type
> 
> /mnt/tmp is mounted from a server running 2.4.21 that has a 3.5TB RAID
> split into 4 partitions of less than 1TB each. The file system on the
> server is XFS.
> 
> /proc/mounts on the client shows:
> 
> lead:/disk1 /mnt/tmp nfs
> rw,v3,rsize=8192,wsize=8192,hard,udp,lock,addr=lead 0 0
> 
> When I use NFSv2, df (or actually statfs()) works as expected - as do
> mounts to other NFS servers (it appears to be just this one server).
> 
> Also, clients running 2.4.X, have no problems with this server.
> 
> Any ideas?
> 
> James Pearson
> 
> 
> -------------------------------------------------------
> SF.Net is sponsored by: Speed Start Your Linux Apps Now.
> Build and deploy apps & Web services for Linux with
> a free DVD software kit from IBM. Click Now!
> http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 
> 



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
