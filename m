From: Matt Schillinger <mschilli@vss.fsi.com>
Subject: RE: Typo in Redhat 8/9 nfs start/stop script
Date: 20 Jun 2003 08:37:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1056116269.18560.5.camel@mosix>
References: <D38AFB3080F3D311807300B0D0203E53033A9616@MERCURY>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-66-136-174-212.dsl.stlsmo.swbell.net ([66.136.174.212] helo=esds.vss.fsi.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19TM4h-00025Q-00
	for <nfs@lists.sourceforge.net>; Fri, 20 Jun 2003 06:37:07 -0700
To: pwitting@Cyveillance.com
In-Reply-To: <D38AFB3080F3D311807300B0D0203E53033A9616@MERCURY>
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

A couple of things.. If i'm reading your /etc/sysconfig/nfs right, you
are using 120 threads, with a 256K input queue.. Is this correct? I
thought that the goal was to allow 32K per thread. Is this not the case?
My understanding was that 256K input queue was to increase NFSD write
performance for 8 threads (the default), and that the input queue should
scale with the number of threads. Is this incorrect?

Also, 2.4.20.. would it be better for me to use that as opposed to
2.4.19? I use a vanilla kernel with an NFSD patch that creates a
workaround for an IRIX < 6.5.13 CWD bug.  If it is recommended to go to
2.4.20, does anyone know if that patch is available for 2.4.20? 
Actually, I've forgotten my source for that patch, so if anyone knows
the address, i'd greatly appreciate recieving that info.


Thanks,

Matt Schillinger
mschilli@vss.fsi.com

On Thu, 2003-06-19 at 15:50, pwitting@Cyveillance.com wrote:
> Good catch. I went over these scripts a while ago and missed this. I did
> find that they are now referencing /etc/sysconfig/nfs for variables, so I
> set one up:
> 
> /etc/sysconfig/nfs 
> 
> # Referenced by Red Hat 8.0 nfs script to set initial values
> #
> # Number of threads start.
> RPCNFSDCOUNT=120
> 
> # yes, no, or auto (attempts to auto-detect support)
> MOUNTD_NFS_V2=auto
> MOUNTD_NFS_V3=auto
> 
> # Should we tune TCP/IP settings for nfs (consumes RAM)
> TUNE_QUEUE=yes
> # 256kb recommended minimum size based on SPECsfs NFS benchmarks
> # default values:
> #       net.core.rmem_default    65535
> #       net.core.rmem_max       131071
> NFS_QS=262144
> 
> ===
> 
> Note that since RedHat 9 uses 2.4.20 this should no longer matter, as nfs
> now determines its own values for queue size on startup as of 2.4.20,
> ignoring whatever values are there.
> 
> >From: Matt Schillinger <mschilli@vss.fsi.com>
> >Date: 19 Jun 2003 14:27:44 -0500
> >
> >Note for any Redhat users that need higher than default input queues for
> >NFS.
> >
> >
> ># Get the initial values for the input sock queues
> ># at the time of running the script.
> >if [ "$TUNE_QUEUE" = "yes" ]; then
> >    RMEM_DEFAULT=`/sbin/sysctl -n net.core.rmem_default`
> >    RMEM_MAX=`/sbin/sysctl -n net.core.rmem_max`
> >    # 256kb recommended minimum size based on SPECsfs NFS benchmarks
> >    [ -z "$NFS_QS" ] && NFS_QS=262144
> >fi
> >
> ># See how we were called.
> >case "$1" in
> >  start)
> >        # Start daemons.
> >        # Apply input queue increase for nfs server
> >        if [ "$TUNE_QUEUE" = "yes" ]; then
> >            /sbin/sysctl -w net.core.rmem_default=$NFSD_QS >/dev/null
> >2>&1
> >            /sbin/sysctl -w net.core.rmem_max=$NFSD_QS >/dev/null 2>&1
> >        fi
> >
> >
> >
> >NOTE THAT when checking that the variable has a value and setting the
> >variable, NFS_QS is used. But when setting the input queues, $NFSD_QS is
> >used.
> >
> >
> >--
> >Matt Schillinger
> >
> >mschilli@vss.fsi.com
> >
> >
> >
> >
> >
> >--__--__--
> >
> >Message: 13
> >From: "Dennis, Richard" <Richard.Dennis@lehman.com>
> >To: nfs@lists.sourceforge.net
> >Date: Thu, 19 Jun 2003 15:56:19 -0400
> >Subject: [NFS] Linux NFS rsize/wsize
> >
> >I've observed something in our Linux NFS environment that I don't
> >understand, and I was hoping someone could help shed some light on this.
> >
> >From a Linux client, I have mounted a share from a Solaris 8 server.  It's
> >mounted with the options: "rw,nosuid,hard,rsize=32768,wsize=32768,intr" on
> >the Linux client, which defaults to UDP.
> >
> >I'm seeing that when I set the rsize and wsize to 32k, packets are read
> >(coming from the Solaris server) in 32k packets, but when I write to this
> >share, Linux frags the file according to my MTU.  Why would the Solaris
> >server accept the rsize, but the linux client not accept the wsize?  (The
> >Solaris server's MTU is also 1500.)
> >
> >Below are the beginnings of the tcpdumps as taken from the client.
> >
> >Thanks in advance.
> >--Rick
> >
> >[root@client root]# tcpdump -s 1500 -vvv -r nfstest_32k_udp_read.out|more
> >
> >16:01:31.260245 nfsclient.412459744 > nfsserver.nfs: 176 access fh
> >211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
> >16:01:31.260699 nfsclient.429236960 > nfsserver.nfs: 180 lookup fh
> >211,9000/1267050 "foo2" (DF) (ttl 64, id 0, len 208)
> >16:01:31.261119 nfsclient.446014176 > nfsserver.nfs: 176 access fh
> >211,9000/1253571 0001 (DF) (ttl 64, id 0, len 204)
> >16:01:31.261589 nfsclient.462791392 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000000000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.265868 nfsclient.479568608 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000008000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.265925 nfsclient.496345824 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000010000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.274669 nfsclient.513123040 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000018000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.274737 nfsclient.529900256 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000020000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.274784 nfsclient.546677472 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000028000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.283490 nfsclient.563454688 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000030000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.284079 nfsclient.580231904 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000038000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.284655 nfsclient.597009120 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000040000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.291038 nfsclient.613786336 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000048000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.291545 nfsclient.630563552 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000050000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.295064 nfsclient.647340768 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000058000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.297166 nfsclient.664117984 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000060000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.299847 nfsclient.680895200 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000068000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.302588 nfsclient.697672416 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000070000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.305327 nfsclient.714449632 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000078000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.308053 nfsclient.731226848 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000080000 (DF) (ttl 64, id 0, len 212)
> >16:01:31.310805 nfsclient.748004064 > nfsserver.nfs: 184 read fh
> >211,9000/1253571 32768 bytes @ 0x000088000 (DF) (ttl 64, id 0, len 212)
> >
> >
> >
> >[root@client root]# tcpdump -s 1500 -vvv -r nfstest_32k_udp_write.out|more
> >
> >16:00:27.177895 nfsclient.3415450336 > nfsserver.nfs: 176 access fh
> >211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
> >16:00:27.178405 nfsclient.3432227552 > nfsserver.nfs: 176 access fh
> >211,9000/1267050 0002 (DF) (ttl 64, id 0, len 204)
> >16:00:27.178827 nfsclient.3449004768 > nfsserver.nfs: 180 lookup fh
> >211,9000/1267050 "foo3" (DF) (ttl 64, id 0, len 208)
> >16:00:27.179221 nfsclient.3465781984 > nfsserver.nfs: 176 access fh
> >211,9000/1267050 001e (DF) (ttl 64, id 0, len 204)
> >16:00:27.179598 nfsclient.3482559200 > nfsserver.nfs: 212 create fh
> >211,9000/1267050 "foo3" (DF) (ttl 64, id 0, len 240)
> >16:00:27.182630 nfsclient.3499336416 > nfsserver.nfs: 176 access fh
> >211,9000/1266907 0000 (DF) (ttl 64, id 0, len 204)
> >16:00:27.185844 nfsclient.3516113632 > nfsserver.nfs: 1472 write fh
> >211,9000/1266907 32768 bytes @ 0x000000000 <unstable> (frag 50541:1480@0+)
> >(ttl 64, len 1500)
> >16:00:27.185864 nfsclient > nfsserver: (frag 50541:1480@1480+) (ttl 64, len
> >1500)
> >16:00:27.185869 nfsclient > nfsserver: (frag 50541:1480@2960+) (ttl 64, len
> >1500)
> >16:00:27.185875 nfsclient > nfsserver: (frag 50541:1480@4440+) (ttl 64, len
> >1500)
> >16:00:27.185883 nfsclient > nfsserver: (frag 50541:1480@5920+) (ttl 64, len
> >1500)
> >16:00:27.185891 nfsclient > nfsserver: (frag 50541:1480@7400+) (ttl 64, len
> >1500)
> >16:00:27.185912 nfsclient > nfsserver: (frag 50541:1480@8880+) (ttl 64, len
> >1500)
> >16:00:27.185918 nfsclient > nfsserver: (frag 50541:1480@10360+) (ttl 64,
> >len
> >1500)
> >16:00:27.185929 nfsclient > nfsserver: (frag 50541:1480@11840+) (ttl 64,
> >len
> >1500)
> >16:00:27.185934 nfsclient > nfsserver: (frag 50541:1480@13320+) (ttl 64,
> >len
> >1500)
> >16:00:27.185939 nfsclient > nfsserver: (frag 50541:1480@14800+) (ttl 64,
> >len
> >1500)
> >16:00:27.185945 nfsclient > nfsserver: (frag 50541:1480@16280+) (ttl 64,
> >len
> >1500)
> >16:00:27.185950 nfsclient > nfsserver: (frag 50541:1480@17760+) (ttl 64,
> >len
> >1500)
> >16:00:27.185956 nfsclient > nfsserver: (frag 50541:1480@19240+) (ttl 64,
> >len
> >1500)
> >16:00:27.185962 nfsclient > nfsserver: (frag 50541:1480@20720+) (ttl 64,
> >len
> >1500)
> >16:00:27.185968 nfsclient > nfsserver: (frag 50541:1480@22200+) (ttl 64,
> >len
> >1500)
> >16:00:27.185974 nfsclient > nfsserver: (frag 50541:1480@23680+) (ttl 64,
> >len
> >1500)
> >16:00:27.185980 nfsclient > nfsserver: (frag 50541:1480@25160+) (ttl 64,
> >len
> >1500)
> >16:00:27.185986 nfsclient > nfsserver: (frag 50541:1480@26640+) (ttl 64,
> >len
> >1500)
> >16:00:27.185992 nfsclient > nfsserver: (frag 50541:1480@28120+) (ttl 64,
> >len
> >1500)
> >16:00:27.185998 nfsclient > nfsserver: (frag 50541:1480@29600+) (ttl 64,
> >len
> >1500)
> >16:00:27.186006 nfsclient > nfsserver: (frag 50541:1480@31080+) (ttl 64,
> >len
> >1500)
> >16:00:27.186015 nfsclient > nfsserver: (frag 50541:408@32560) (ttl 64, len
> >428)
> >16:00:27.187272 nfsclient.3532890848 > nfsserver.nfs: 1472 write fh
> >211,9000/1266907 32768 bytes @ 0x000008000 <unstable> (frag 50542:1480@0+)
> >(ttl 64, len 1500)
> >16:00:27.187291 nfsclient > nfsserver: (frag 50542:1480@1480+) (ttl 64, len
> >1500)
> >16:00:27.187296 nfsclient > nfsserver: (frag 50542:1480@2960+) (ttl 64, len
> >1500)
> >16:00:27.187302 nfsclient > nfsserver: (frag 50542:1480@4440+) (ttl 64, len
> >1500)
> >16:00:27.187307 nfsclient > nfsserver: (frag 50542:1480@5920+) (ttl 64, len
> >1500)
> >
> >---------------------------------------------------------------------------
> >---
> >This message is intended only for the personal and confidential use of the
> >designated recipient(s) named above.  If you are not the intended recipient
> >of
> >this message you are hereby notified that any review, dissemination,
> >distribution or copying of this message is strictly prohibited.  This
> >communication is for information purposes only and should not be regarded
> >as
> >an offer to sell or as a solicitation of an offer to buy any financial
> >product, an official confirmation of any transaction, or as an official
> >statement of Lehman Brothers.  Email transmission cannot be guaranteed to
> >be
> >secure or error-free.  Therefore, we do not represent that this information
> >is
> >complete or accurate and it should not be relied upon as such.  All
> >information is subject to change without notice.
> >
> >
> >
> >
> >--__--__--
> >
> >_______________________________________________
> >NFS maillist  -  NFS@lists.sourceforge.net
> >https://lists.sourceforge.net/lists/listinfo/nfs
> >
> >
> >End of NFS Digest
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs





-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
