From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: lockd / statd fun (sorry)
Date: Tue, 27 Apr 2004 12:49:17 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083084557.2616.45.camel@lade.trondhjem.org>
References: <200404231137.29216.gdh@acentral.co.uk>
	 <20040427134343.GB1330@acentral.co.uk> <20040427153200.GC6836@suse.de>
	 <200404271647.27029.gdh@acentral.co.uk>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIVlp-000719-N5
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 09:49:21 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BIVlp-0006Ev-DC
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 09:49:21 -0700
To: Gavin Hamill <gdh@acentral.co.uk>
In-Reply-To: <200404271647.27029.gdh@acentral.co.uk>
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

On Tue, 2004-04-27 at 11:47, Gavin Hamill wrote:

> I'm just about out of ideas on this one, and am ready to just mount the 
> NFS-root with the 'nolock' option - this works, and lets openoffice's setup 
> run (it requires locking..) but again, it's just 'a fix' and not The 
> Solution.

Neither is keeping /var/lib/nfs on a ramdisk.

The problem then is that if you crash and reboot, rpc.statd will
restart, but it will not notify your server that you rebooted (because
/var/lib/nfs will have been wiped by the reboot). The server may then
end up hanging on to a bunch of locks that it thinks you still own.

/var/lib/nfs should *always* be on permanent storage if you want to use
locking.

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
