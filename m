From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: NFS server problem with kernel 2.6.8.1
Date: Tue, 17 May 2005 16:51:55 -0400 (EDT)
Message-ID: <Pine.LNX.4.58.0505171649400.6834@chaos.egr.duke.edu>
References: <428A57C1.7070807@pauli.utmb.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DY92k-0008Fw-UC
	for nfs@lists.sourceforge.net; Tue, 17 May 2005 13:51:58 -0700
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DY92j-0007VK-D7
	for nfs@lists.sourceforge.net; Tue, 17 May 2005 13:51:58 -0700
To: Yuan Xu <yuan@pauli.utmb.edu>
In-Reply-To: <428A57C1.7070807@pauli.utmb.edu>
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

On Tue, 17 May 2005 at 3:44pm, Yuan Xu wrote

> Dear all
> This problem is caused by running up2date of Redhat linux!!!

There is no Redhat Linux.  There is Red Hat Enterprise Linux, and there is 
Fedora.  Which you are running makes a big difference.

> When I was running  kernel  2.4.21-27.0.2.ELsmp my nfs server worked 
> fine and after upgrading to 2.6.x via Redhat RHN my NFS sever no longer 
> works.

The first kernel is from RHEL3, which has no option for a 2.6 kernel via 
RHN.  Did you try to up2date the server to RHEL4?  In general, that is not 
recommended.

> Right now the NFS server is running kernel 2.6.8.1 SMP, x86_64 and I can 

That's not a Red Hat kernel.

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
