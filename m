From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: NFS performance question / (a)sync
Date: Fri, 26 Nov 2004 14:08:09 +0100
Message-ID: <200411261408.10977.bernd-schubert@web.de>
References: <021801c4d3b3$e40fe470$9842a8c0@thorsten1te>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CXfpk-00029v-8w
	for nfs@lists.sourceforge.net; Fri, 26 Nov 2004 05:08:20 -0800
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CXfph-00004u-Pg
	for nfs@lists.sourceforge.net; Fri, 26 Nov 2004 05:08:20 -0800
Received: from euklid.pci.uni-heidelberg.de (euklid.pci.uni-heidelberg.de [129.206.21.104])
	by relay.uni-heidelberg.de (8.12.10/8.12.10) with ESMTP id iAQD8C4i012673
	for <nfs@lists.sourceforge.net>; Fri, 26 Nov 2004 14:08:12 +0100 (MET)
Received: from bernd by euklid.pci.uni-heidelberg.de with local (Exim 3.35 #1 (Debian))
	id 1CXfpb-0004YN-00
	for <nfs@lists.sourceforge.net>; Fri, 26 Nov 2004 14:08:11 +0100
To: nfs@lists.sourceforge.net
In-Reply-To: <021801c4d3b3$e40fe470$9842a8c0@thorsten1te>
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

Hi Thorsten,

> Is it "normal" that I reach only 0,5 - 2,0 megabyte per socond when using
> sync-transfer? I know what this means, but I did not expect such a
> performance drop.

did you get those results on the drbd device? This was just (this week)=20
discussed on the drbd list, see the archives. Sync vs. async was also just=
=20
discussed on this list.


Cheers,
 Bernd

=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
