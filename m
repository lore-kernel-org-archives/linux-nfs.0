From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: NFS/UDP slow read, lost fragments
Date: Tue, 14 Oct 2003 23:17:13 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F8CBC39.3020002@RedHat.com>
References: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain>	<20030925174426.B787@muppet.kendall.corp.akamai.com>	<shs1xu430p2.fsf@charged.uio.no>	<20030926170759.H787@muppet.kendall.corp.akamai.com>	<3F8B4F7B.4010907@RedHat.com> <16268.3496.615917.119237@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9cAc-0003MY-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Oct 2003 20:17:54 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A9cAb-0005mq-PK
	for nfs@lists.sourceforge.net; Tue, 14 Oct 2003 20:17:53 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <16268.3496.615917.119237@charged.uio.no>
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



Trond Myklebust wrote:

>Could you try using the slight variation in
>  
>
It didn't seem to help much... here the numbers...

linux-2.4.23-pre7
Soft mount:
EIO calls      retrans   rate
0   128042     2105      6.20Mbps to 6.08Mbps
0   128040     1916      6.28Mbps to 6.09Mbps
0   128044     1936      6.37Mbps to 6.12Mbps
Hard mount:
    128048     1995      6.29Mbp  to 6.09Mbps
    128033     2075      6.21Mbps to 6.07Mbps
    128037     2015      6.23Mbps to 6.10Mbps

with Trond's Original Patch
Soft mount:
EIO calls      retrans   rate
0   128043     1817      6.36Mbps to 6.17Mbps
0   128036     1630      6.38Mbps to 6.21Mbps
0   128038     1848      6.35Mbps to 6.18Mbps
Hard mount:
    128043     1706      6.30Mbps to 6.22Mbps
    128041     1778      6.33Mbps to 6.18Mbps
    128041     1891      6.31Mbps to 6.16Mbps

with Trond's Original Patch w/ Brian's patch
Soft mount:
EIO calls      retrans   rate
0   128039     1626      6.45Mbps to 6.22Mbps
0   128043     1896      6.31Mbps to 6.20Mbps
0   128036     1948      6.32Mbps to 6.15Mbps
Hard mount:
    128034     1792      6.41Mbps to 6.17Mbps
    128039     1823      6.29Mbps to 6.17Mbps
    128043     1903      6.42Mbps to 6.18Mbps
with Trond's New Patch
Soft mount:
EIO calls      retrans   rate
    128041     1954      6.33Mbps to 6.11Mbps
    128040     1897      6.31Mbps to 6.16Mbps
    128039     1758      6.26Mbps to 6.17Mbps
Hard mount:
    128043     1808      6.40Mbps to 6.19Mbps
    128033     1671      6.37Mbps to 6.20Mbps
    128042     1852      6.37Mbps to 6.17Mbps

Again this is 10 threads reading 10 100m files from the same filesystem

SteveD.



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
