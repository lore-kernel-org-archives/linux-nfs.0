From: <JACOB_LIBERMAN@Dell.com>
Subject: Capture nfs debug info to syslog (linux)
Date: Fri, 14 May 2004 10:02:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <90D99853F9131D4388534489DA4FCBA60A17B7@ausx2kmpc104.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOeCv-0008LI-Dz
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 08:02:41 -0700
Received: from ausc60pc101.us.dell.com ([143.166.85.206])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BOeCv-0007Ra-AA
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 08:02:41 -0700
To: <nfs@lists.sourceforge.net>
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

All,

What is the best way to capture NFS debugging information to syslog?
Basically I am trying to find a way to gather as much information as
possible that can be used to troubleshoot NFS. I also feel that this
would be a great addition to the NFS-HOWTO.

I have checked the nfs-howto, included distribution documentation, and
searched the nfs mailing list archives.

I am running nfs-utils-0.3.3 and portmap-4.0-38 kernel-2.4.9-e.40smp
(Red Hat Linux AS 2.1)

So far I have found the following:=20

1. starting rpc.mountd with "--debug all" (RPCMOUNTDOPTS=3D"--debug all"
in /etc/sysconfig/nfs)
2. configuring syslog to capture debug level information
3. echoing 32767 into /proc/sys/sunrpc/{nfs_debug, nfsd_debug,
rpc_debug}
4. restarting syslog, nfs, and portmap=20

I have tried reviewing the source code in
/usr/include/linux/{lockd/debug.h, nfsd/debug.h, sunrpc/debug.h} and
nfs_fs.h. The RPCDBG_, NFSDBG_, and NFSDDBG_ variables all seem to take
values up to 65535 (0xFFFF). My programming skills are a bit rusty, so
please make all replies as detailed (and human readable) as possible.

Thanks, jacob=20




-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
