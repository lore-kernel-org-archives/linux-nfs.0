From: Chris Penney <cpenney@gmail.com>
Subject: Use of SMP on NFS server
Date: Thu, 24 Mar 2005 22:39:15 -0500
Message-ID: <111aefd050324193972d1a5eb@mail.gmail.com>
Reply-To: penney@msu.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DEffP-0005CA-JC
	for nfs@lists.sourceforge.net; Thu, 24 Mar 2005 19:39:23 -0800
Received: from wproxy.gmail.com ([64.233.184.197])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DEffO-0007Qk-6Z
	for nfs@lists.sourceforge.net; Thu, 24 Mar 2005 19:39:23 -0800
Received: by wproxy.gmail.com with SMTP id 68so966324wri
        for <nfs@lists.sourceforge.net>; Thu, 24 Mar 2005 19:39:15 -0800 (PST)
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

I've heard from some that there are issues with NFS + SMP when using
the 2.6 kernel.  Assuming I'm using 2.6.11.5 w/ the NFS-ALL patches
applied should I be concerned about running SMP (dual cpu pentium 4
doing pretty much only NFSv3 TCP, but looking toward NFSv4)?

Assuming it's ok to use SMP on a heavy use NFS server, should I enable
or disable hyperthreading?  I'd assume that for NFS hyperthreading
would be good, but that's only a guess.

   Chris


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
