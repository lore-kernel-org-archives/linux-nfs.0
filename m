From: Bradford Arrington <brada@cadence.com>
Subject: default nfs mount options from linux to linux
Date: Thu, 21 Apr 2005 18:01:59 -0700
Message-ID: <1114131719.12180.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DOmXp-0000ON-NT
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 18:01:21 -0700
Received: from mailgate2.cadence.com ([158.140.2.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DOmXo-0004rx-BL
	for nfs@lists.sourceforge.net; Thu, 21 Apr 2005 18:01:21 -0700
Received: from exmbx02sj.global.cadence.com (exmbx02sj.Cadence.COM [158.140.128.151])
	by mailgate2.Cadence.COM (8.9.3/8.9.3) with ESMTP id RAA12061
	for <nfs@lists.sourceforge.net>; Thu, 21 Apr 2005 17:58:59 -0700 (PDT)
To: nfs@lists.sourceforge.net
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


Does anyone know what or how to find the default mount option are when
mounting an nfs volume?
example
mount linuxnfs:/export /mnt 

How do I find the rsize/wsize and any other options? (that are default)

I am lead to believe that the nfs man page information is false for
r/wsize 1k (no way) (udp default is correct though). If I set the
r/wsize to 1k performance is very slow. In a "vanilla" default as above
it has the fastest iozone benchmarks.

Thanks,
-Brad



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
