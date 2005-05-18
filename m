From: "Henrik Schmiediche" <henrik@stat.tamu.edu>
Subject: RE: Extremely high load on NFS clients wen the NFS server is down...
Date: Wed, 18 May 2005 14:51:16 -0500
Message-ID: <200505181951.j4IJpkT1014772@s7.stat.tamu.edu>
References: <Pine.LNX.4.58.0505181536150.6834@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "'Steve Dickson'" <SteveD@redhat.com>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DYUa8-0006av-1B
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:51:52 -0700
Received: from s7.stat.tamu.edu ([165.91.117.61])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DYUa7-000464-5c
	for nfs@lists.sourceforge.net; Wed, 18 May 2005 12:51:51 -0700
To: "'Joshua Baker-LePain'" <jlb17@duke.edu>
In-Reply-To: <Pine.LNX.4.58.0505181536150.6834@chaos.egr.duke.edu>
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


That did it. Thanks.

   - Henrik


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Joshua Baker-LePain
Sent: Wednesday, May 18, 2005 2:37 PM
To: Henrik Schmiediche
Cc: 'Steve Dickson'; nfs@lists.sourceforge.net
Subject: RE: [NFS] Extremely high load on NFS clients wen the NFS server is
down...

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



-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
