From: Chris Worley <cworley@lnxi.com>
Subject: Stopping NFS, ip address take over, zero-copy NFS for 2.4.21, and
 misc
Date: 18 Sep 2003 09:59:51 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1063900790.8031.9644.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A01Eh-0006vi-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 09:02:27 -0700
Received: from [208.177.141.226] (helo=localhost.lnxi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A01Eg-0005wN-B1
	for nfs@lists.sourceforge.net; Thu, 18 Sep 2003 09:02:26 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by localhost.lnxi.com (8.11.6/8.11.6) with ESMTP id h8IFxpM18381
	for <nfs@lists.sourceforge.net>; Thu, 18 Sep 2003 09:59:51 -0600
To: nfs@lists.sourceforge.net
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

Hi,

background...

Configuration: FC SAN serving all luns to multiple dual-cpu 3.0GHz XEON
I/O servers (using Qlogic 24xx HBA's) running GFS, re-exported via NFS
to about a dozen clients per NFS server.  Each I/O server has 96 nfsd
threads running.  NFS is being served over Myrinet over IP.  Any
problems listed below are true for both NFS over Ethernet and over
Myrinet over IP (but Myrinet is a lot more stable, with no frag
problems).  Servers and clients all running RH7.3 w/ a 2.4.21 kernel.
 
Patches: GFS, Direct-I/O and related kernel patches (doesn't seem to
work with IOZone "-I" option), and NFSSVC_MAXBLKSIZE set to 32768. Any
problems listed below are both with and without these changes (except
GFS patches, I gotta have those).  Qla23x0 driver: both SG_SEGMENTS and
MAX_OUTSTANDING_COMMANDS set to 4096. 

Clients mount with options (all performance related):

	bg,nocto,intr,vers=3,rsize=32768,wsize=32768,hard,retrans=1000,timeo=3,nolock,async

1)  NFS won't shutdown. 

No matter the number of nfsd threads, NFS won't shutdown.  It sticks and
eventually times-out trying to kill the nfsd threads.  With only one
client, this isn't a problem.  So it's number-of-clients related.

If NFS doesn't shutdown, then I can't gracefully unmount and shutdown
GFS... which means the only way to reboot an NFS server is take down the
network, and let the lock server fence the I/O server.  Not pretty.

Any ideas on forcing NFS down?

2) IP address takeover between NFS servers.

With NFS stateless, and not running lock servers, I thought a simple IP
address takeover scheme (when an I/O server goes down, another just adds
the failed server's IP address as a virtual interface) would allow
clients to immediately renegotiate with the same IP address pointing to
another NFS server (serving the same partitions).  The take-over is
successful: the clients can communicate with the new I/O server, but I
get "permission denied" (as root or otherwise) on the NFS mounted
partitions most of the time (sometimes it works).

What am I missing?

3) Zero-copy NFS patches had been available for kernels prior to
2.4.21... but are missing from Trond's 2.4.21 patches.  I have to use
2.4.21 for the time being (can't use 2.6).  

Is there hope of getting these patches for this kernel rev?

4) I Need to have more outstanding SCSI requests.

The SAN I'm using can parallelize many more outstanding SCSI requests
than I'm sending it.  The Qlogic scatter-gather list size and
outstanding command queue seem to be big enough to handle more
requests.  I'm seeing, at most, 5 outstanding requests per NFS server.

Is there something at the SCSI layer or driver layer that will allow for
more outstanding I/O requests?  

Is there a way to find out if this is a SCSI layer problem, vs. driver
or NFS or GFS file system problem (i.e. something in proc I can monitor
to see outstanding requests at these different levels)?

5) How come the "retrans" and "timeo" values set on the client mount
don't show up in /proc/mounts?

6) Any performance hints I'm missing?

Thanks,

Chris



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
