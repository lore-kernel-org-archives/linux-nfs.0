From: Chris Penney <cpenney@gmail.com>
Subject: SMP, NFS, and 2.6
Date: Tue, 29 Mar 2005 15:58:02 -0500
Message-ID: <111aefd050329125848955802@mail.gmail.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DGNmr-0005G8-OT
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 12:58:09 -0800
Received: from wproxy.gmail.com ([64.233.184.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DGNmq-0007Cf-CU
	for nfs@lists.sourceforge.net; Tue, 29 Mar 2005 12:58:09 -0800
Received: by wproxy.gmail.com with SMTP id 69so648664wra
        for <nfs@lists.sourceforge.net>; Tue, 29 Mar 2005 12:58:02 -0800 (PST)
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

I've heard from some (via google searchs) that there are issues with
NFS + SMP when using the 2.6 kernel.  Assuming I'm using 2.6.11.5 w/
the NFS-ALL patches applied should I be concerned about running SMP
(dual cpu pentium 4 doing pretty much only NFSv3 TCP, but looking
toward NFSv4)?

Assuming it's ok to use SMP on a heavy use NFS server, should I enable
or disable hyperthreading?  I'd assume that for NFS hyperthreading
would be good, but that's only a guess.

Thanks,

   Chris


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
