From: Olaf Kirch <okir@suse.de>
Subject: Re: lockd / statd fun (sorry)
Date: Tue, 27 Apr 2004 17:32:00 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040427153200.GC6836@suse.de>
References: <200404231137.29216.gdh@acentral.co.uk> <200404231332.07891.bernd-schubert@web.de> <200404231248.30956.gdh@acentral.co.uk> <20040423115702.GQ3491@suse.de> <20040427134343.GB1330@acentral.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIUZ1-0006r8-Ur
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 08:32:03 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BIUZ1-0006Rg-LB
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 08:32:03 -0700
To: Gavin Hamill <gdh@acentral.co.uk>
In-Reply-To: <20040427134343.GB1330@acentral.co.uk>
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

On Tue, Apr 27, 2004 at 02:43:43PM +0100, Gavin Hamill wrote:
> OK, I'm assuming here that statd is only run by the machine  running nfsd and
> exporting filesystems, and /usr/sbin/rpc.statd is definately in the process list

No, statd needs to run on the client as well.

> Moving onto the files in /var/lib, everything seems to be in order, but I never see any
> files written to /var/lib/nfs/sm.

Files should appear in /var/lib/nfs/sm while a lock is held, and disappear
shortly after the lock is released.

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
