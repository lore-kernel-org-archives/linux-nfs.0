From: Serge Sozonoff <serge@sozonoff.com>
Subject: Re: NFS and linux 2.6 series kernels
Date: Mon, 08 Mar 2004 16:18:05 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <404C8EAD.50705@sozonoff.com>
References: <482A3FA0050D21419C269D13989C61130435DD0E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Lever, Charles" <Charles.Lever@netapp.com>
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DD0E@lavender-fe.eng.netapp.com>
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

Hi Charles,

 > can you report to the list your mount options and the output of nfsstat
 > -c
 > on your client (after such a transfer was attempted)?

Yes, I am using this as my mount options:
mount -o rsize=32768,wsize=32768,nfsvers=3,noatime nas:/Access.Share/system_images /mnt/images

I have also tried with a few different wsize and rsize like for example 8192 and I tried mounting with no options at all.
I am using UDP and cannot try TCP because my NAS server does not currently support it.

This is the output of nfsstat -c on the client after about 400Mb transfered at which point I canceled the transfer because otherwise it would take forever.
Interestingly the transfer starts at a screeming speed in comparison to a 2.4 kernel NFS client but then it all stops and kind
of bumps along. I am running on 100Mpbs ethernet, non switched but for the moment there is no other traffic on the lan.
My test basically consists of running partimage to back up my disk partitions to the nas.

Client rpc stats:
calls      retrans    authrefrsh
42095      211        0
Client nfs v2:
null       getattr    setattr    root       lookup     readlink
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 7       0% 0       0% 4       0% 8       0% 0       0%
read       write      create     mkdir      symlink    mknod
0       0% 41747  99% 2       0% 0       0% 0       0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
1       0% 0       0% 0       0% 0       0% 0       0% 0       0%
fsstat     fsinfo     pathconf   commit
317     0% 1       0% 0       0% 8       0%


Currently I am running 2.6.4-rc1-mm2 but I have also tried with kernel-2.6.3-gentoo-r2.

Thanks,
Serge




-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
