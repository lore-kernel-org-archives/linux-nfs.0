From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: Re: default nfs mount options from linux to linux
Date: Fri, 22 Apr 2005 08:47:23 -0700
Message-ID: <OF05A65FF9.8E6B5618-ON88256FEB.00566EB2-88256FEB.0056BCC7@us.ibm.com>
References: <1114131719.12180.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DP0NW-0005lu-L4
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 08:47:38 -0700
Received: from e31.co.us.ibm.com ([32.97.110.129])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1DP0NT-0007lh-V1
	for nfs@lists.sourceforge.net; Fri, 22 Apr 2005 08:47:38 -0700
Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j3MFlRua433880
	for <nfs@lists.sourceforge.net>; Fri, 22 Apr 2005 11:47:27 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j3MFlRqT234716
	for <nfs@lists.sourceforge.net>; Fri, 22 Apr 2005 09:47:27 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j3MFlQ3Y028716
	for <nfs@lists.sourceforge.net>; Fri, 22 Apr 2005 09:47:26 -0600
In-Reply-To: <1114131719.12180.8.camel@localhost>
To: Bradford Arrington <brada@cadence.com>
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

Mount the volume without options and check /proc/mounts.  Note that some 
options may differ based on negotiation with the server.

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR USA
503-578-4187   IBM Tie-line 775-4187




Bradford Arrington <brada@cadence.com> 
Sent by: nfs-admin@lists.sourceforge.net
04/21/2005 06:01 PM

To
nfs@lists.sourceforge.net
cc

Subject
[NFS] default nfs mount options from linux to linux







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




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
