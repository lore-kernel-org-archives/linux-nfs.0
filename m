From: Bruce Allan <bruce.allan@us.ibm.com>
Subject: Re: ANNOUNCE: nfs-utils 1.0.7-pre1
Date: Fri, 3 Dec 2004 10:07:11 -0800
Message-ID: <OF5EAC57B5.E871608D-ON08256F5F.00634442-08256F5F.00638979@us.ibm.com>
References: <16815.63554.437489.308079@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaHq5-00008D-Ow
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:07:29 -0800
Received: from e33.co.us.ibm.com ([32.97.110.131])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1CaHq4-0004OH-KX
	for nfs@lists.sourceforge.net; Fri, 03 Dec 2004 10:07:29 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iB3I7FDr070214
	for <nfs@lists.sourceforge.net>; Fri, 3 Dec 2004 13:07:16 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iB3I7Ej1363434
	for <nfs@lists.sourceforge.net>; Fri, 3 Dec 2004 11:07:14 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iB3I7D2D010806
	for <nfs@lists.sourceforge.net>; Fri, 3 Dec 2004 11:07:13 -0700
In-Reply-To: <16815.63554.437489.308079@cse.unsw.edu.au>
To: Neil Brown <neilb@cse.unsw.edu.au>
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

Doesn't compile (missing event.h and nfsidmap.h).

gcc -g -O2 -D_GNU_SOURCE -DHAVE_TCP_WRAPPER -I../../support/include 
-I/usr/include -Wall  -pipe  -DVERSION="\"nfs-utils 1.0.7-pre1\"" 
-DNFS3_SUPPORTED -M atomicio.c cfg.c idmapd.c setproctitle.c strlcat.c 
strlcpy.c > .depend
idmapd.c:48:19: event.h: No such file or directory
idmapd.c:61:22: nfsidmap.h: No such file or directory

Regards,
---
Bruce Allan  <bruce.allan@us.ibm.com>
Software Engineer, Linux Technology Center
IBM Corporation, Beaverton OR
503-578-4187   IBM Tie-line 775-4187




Neil Brown <neilb@cse.unsw.edu.au> 
Sent by: nfs-admin@lists.sourceforge.net
12/02/2004 09:23 PM

To
nfs@lists.sourceforge.net
cc

Subject
[NFS] ANNOUNCE: nfs-utils 1.0.7-pre1








I have made available a pre-release of nfs-utils 1.0.7.

It can be downloaded from 
  http://sourceforge.net/project/showfiles.php?group_id=14
or
  http://www.{countrycode}.kernel.org/pub/linux/utils/nfs/


The reason for the pre-release is that there are a number of changes that
I haven't had a chance to test properly, and some that I am not in a 
position
to test.

There are an assortment of bug-fixes, some support for fail-over 
clustering,
and support for 'gss' authentication.

I would appreciate it if people could check that it compiles and works for 
them,
and let me know the success rate.

I hope to put this out as a final 1.0.7 before Christmas.  Having lots of 
people 
say "Yes, I've tried it, and it works OK" would make a great Christmas 
present :-)

NeilBrown 03-December-2004


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
