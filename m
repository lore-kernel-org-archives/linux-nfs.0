From: "Baker, Byran" <Byran_Baker@bmc.com>
Subject: Re: nfs performance problem
Date: Thu, 7 Nov 2002 09:19:44 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CDC5FB5947D3D3119E2D00A0C9B6AF2D06777678@es06-hou.bmc.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from camaro.bmc.com ([198.207.223.231] helo=creeper.bmc.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189oS5-0006Du-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Nov 2002 07:20:14 -0800
Received: from ec02-hou.bmc.com (localhost [127.0.0.1])
	by creeper.bmc.com (8.10.2/8.10.2) with ESMTP id gA7FJkf26852
	for <nfs@lists.sourceforge.net>; Thu, 7 Nov 2002 09:19:46 -0600 (CST)
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

We have a couple of NFS servers with 3ware cards.  One is a 3ware 7850 (8
Maxtor 160GB - 5400RPM) and one is a 3ware 7500-12, both configured with
RAID 5 + Hot Spare.  I have all the latest NFS patches applied.  If I access
an NFS mounted directory on one of these systems and copy a bunch of little
files (1-2KB), I get 150-250 tps.  If I access larger files (90% > 1MB each)
I will normally see 25-60MB/s transfer with 500-700 tps, with peaks of over
1000 tps - A good indication that disk seek is to blame for the problem with
the small files.

Thanks,
-Byran

From: "Matt Heaton" <admin@0catch.com>
To: "poczta.dotcom.pl" <myciel@dotcom.pl>,
	<nfs@lists.sourceforge.net>
Subject: Re: [NFS] nfs performance problem
Date: Tue, 5 Nov 2002 13:22:25 -0700

I have 3ware cards as well (2 7500 Series 8 drive), just like yours.  ALso
with 120 GIG drives (7200)
RPM.  Whever I get 150-200 tps in iostat then my NFS runs SO SLOW.  I also
only get 1 MB, to 1.5 MB
over NFS.  The local speed seems to be ok, not great though.   MY OPINION is
that this is because of seek time on the raid
array.   I am serving very small files, just like you are.  I am requesting
about 200-300 files per second from
each NFS server.  So even though our throughput of only 1.5 MB isn't high.
The number of files per second is
actually quite high, and causes things to slow down because of seek time
issues.  PLEASE GIVE US CACHEFS SOMEONE??

Does anyone have experience with IDE Raid arrays that get over 250 tps in
iostat that work fine?  I would
be VERY VERY VERY interested to find out.

L8r...

Matt


-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
