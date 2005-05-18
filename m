From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: RE: Extremely high load on NFS clients wen the NFS server is
 down...
Date: Wed, 18 May 2005 15:36:39 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0505181536150.6834@chaos.egr.duke.edu>
References: <200505181912.j4IJCS8v011808@s7.stat.tamu.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "'Steve Dickson'" <SteveD@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYULT-0005Aj-U8
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:36:43 -0700
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYULS-0006g6-32
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:36:43 -0700
To: Henrik Schmiediche <henrik@stat.tamu.edu>
In-Reply-To: <200505181912.j4IJCS8v011808@s7.stat.tamu.edu>
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

On Wed, 18 May 2005 at 2:11pm, Henrik Schmiediche wrote

> Thanks for your response. The command 'echo t > /proc/sysrq-trigger' does
> nothing that I can tell. Is there something I need to do to enable this
> feature?

echo 1 > /proc/sys/kernel/sysrq

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
