From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: 3 bugs with UDP mounts
Date: Mon, 22 Apr 2002 18:23:24 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <6440EA1A6AA1D5118C6900902745938E50CEBE@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01-a.netapp.com ([198.95.226.53])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zp1p-0007HY-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 18:23:33 -0700
To: "'Andrew Ryan'" <andrewr@nam-shub.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

hi all-

> kernel: 2.4.17+NFS-ALL-2002-Jan-17, 2.4.19pre7+NFS-ALL. Both 
> SMP on a 2-CPU 
> system.
> nfs-utils-0.3.1-13.7.2.1, mount-2.11g-5
> server: NetApp

for the whole list:  when reporting issues against NetApp filers,
please mention the OnTap version and filer hardware if you can...
that would help us a lot!  thanks!

> network: 100baseTx-FD on client, gigE-FD on server
> 
> 1. UDP read performance (v2 and v3) on large files is really 
> poor. [....]
> I can get excellent read performance, as long as the files 
> are relatively small.

you are probably hitting the network speed step down between
the GbE filer and the 100Mb client.  the first packet loss
will cause your read throughput to drop.  i'll bet your
small file knee occurs right about at the size of your switch's
memory buffer.

have you tried this test with TCP?

> With a Solaris client, mounting the same server UDP (and also 
> 100baseTx-FD), reading the same file is done at a 
> consistently high speed, 
> so it definitely seems to be a linux-specific problem.

Solaris may have workarounds (like a loose interpretation of
Van Jacobsen) or bugs that allow this to work well.  just a guess.

> 2. I accidentally mounted an NFS filesystem 
> "udp,nfsvers=3,rsize=32768,wsize=32768". For one, I don't exactly 
> understand why this was allowed, since it doesn't seem like I 
> should be 
> allowed to mount NFS/UDP with these options.

we have filers mounted with UDP and r/wsize=32K from a R7.2 system
running 2.4.19pre.  NFS over UDP allows r/wsize up to 32K.  the
limitation is the number of bytes possible in a single fragmented
IP packet which is about 65536 bytes.  the RPC/UDP header overhead
for a 64K r/wsize cause it not to fit in a single IP packet.

> Also, this creates a 
> disagreement between what is returned by the 'mount' command and 'cat 
> /proc/mounts'.
> 
> The relevant line from the 'mount' command shows this:
> fileserver:/vol/stage/data on /shared/data type nfs 
> (rw,udp,nfsvers=3,rsize=32768,wsize=32768,intr,hard,addr=192.1
> 68.100.240)
> 
> while the relevant line from /proc/mounts shows this:
> fileserver:/vol/stage/data /shared/data nfs 
> rw,v3,rsize=8192,wsize=8192,hard,intr,udp,lock,addr=fileserver 0 0
> This may be a problem with my version of mount or nfs-utils, 
> anyone seen 
> this before?

the mismatch between the requested size and the reported mount
options i have never seen before, and looks like a bug to me.
your version of mount may not allow more than 8k r/wsize because
of old limitations on the Linux server?

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
