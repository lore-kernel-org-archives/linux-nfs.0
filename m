From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 14:25:30 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAx4E-0001XY-LT
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:25:38 -0800
Received: from harp.ngdc.noaa.gov ([140.172.178.33])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAx4D-0002Mr-6d
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:25:38 -0800
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id j2ELPUdf006540
	for <nfs@lists.sourceforge.net>; Mon, 14 Mar 2005 14:25:30 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id j2ELPU7x006536
	for <nfs@lists.sourceforge.net>; Mon, 14 Mar 2005 14:25:30 -0700
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


we are seeing some really bizarre strange behaviour on our nfs systems.
essentially a system will hum along nicely, running binaries from our nfs
server without issue.  for no apparent reason these binaries suddenly become
corrupt on the client side and stop working.  running md5sum on the affected
binary on a 'good' host and a 'bad' one shows them to, in fact, be different.

doing and unmount and remount fixes the issue.  obviously so does a reboot.
both are temporary fixes though - eventually a node will start getting corrupt
binaries - or perhaps not.

the server is not under undue stress as it serves only code and no data
traffic is hitting it (we use vsftp to move data around).  none of the
machines seems to logging any errors - server nor client.  all of our systems
are the same:

   ~ > uname -srm
   Linux 2.4.21-27.0.2.EL i686

   ~ > cat /etc/redhat-release
   Red Hat Enterprise Linux WS release 3 (Taroon Update 4)

   ~ > cat /proc/cpuinfo | grep model
   model           : 2
   model name      : Intel(R) Xeon(TM) CPU 2.80GHz
   model           : 2
   model name      : Intel(R) Xeon(TM) CPU 2.80GHz
   model           : 2
   model name      : Intel(R) Xeon(TM) CPU 2.80GHz
   model           : 2
   model name      : Intel(R) Xeon(TM) CPU 2.80GHz

   ~ > free -b
   total       used       free     shared    buffers     cached
   Mem:    4082057216 4040855552   41201664          0   16977920 3698454528
   -/+ buffers/cache:  325423104 3756634112 Swap:   6325055488   96333824 6228721664

   ~ > rpm -qa | grep nfs
   redhat-config-nfs-1.0.13-6
   nfs-utils-1.0.6-33EL

all the machines are on the same subnet with one hop to the nfs server.

has anyone seen this behaviour?  and ideas what the issue might be?  we cannot
be certain but think the issue is associated with the latest kernel.  the
reason we cannot be certain is that we've not been running much for the last
few weeks and just started seeing the problem - we booted to the latest kernel
about a month ago.

i'm not even sure where to start looking here but the symtoms seems to point
to some sort of client side caching issue... any input appreciated.

kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
