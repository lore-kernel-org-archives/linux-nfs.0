From: Gavin Hamill <gdh@acentral.co.uk>
Subject: Re: lockd / statd fun (sorry)
Date: Tue, 27 Apr 2004 19:15:59 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040427181559.GA9200@acentral.co.uk>
References: <200404231137.29216.gdh@acentral.co.uk> <20040427134343.GB1330@acentral.co.uk> <20040427153200.GC6836@suse.de> <200404271647.27029.gdh@acentral.co.uk> <1083084557.2616.45.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BIX5Y-0001ZW-Am
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 11:13:48 -0700
Received: from acentral.co.uk ([213.232.83.29] helo=eddie.acentral.co.uk)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BIX5P-0007Or-PT
	for nfs@lists.sourceforge.net; Tue, 27 Apr 2004 11:13:43 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1083084557.2616.45.camel@lade.trondhjem.org>
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

On Tue, Apr 27, 2004 at 12:49:17PM -0400, Trond Myklebust wrote:
> On Tue, 2004-04-27 at 11:47, Gavin Hamill wrote:
> 
> > but again, it's just 'a fix' and not The Solution.
> 
> Neither is keeping /var/lib/nfs on a ramdisk.
> 
> /var/lib/nfs should *always* be on permanent storage if you want to use
> locking.

Ah I'd certainly not taken that into consideration - I assumed (always 
bad, I know) it would reset any locks when the same client remounted the 
same export at reboot.

OK, given that the machines have no local permanent storage, it seems
that's solved the problem for me - I must disable locking completely.

It's fortunate that the rootfs export is mounted read-only, and the
home-directories export are never shared between multiple users. That, 
and the users are not running very demanding applications.

Plus, if the worst happens, it would take only a few minutes to restore 
a corrupted file from backups, or re-create their userprofile entirely.

Thanks for the advice, NFS has been around for a long time, and I've 
known nothing about it until the last few weeks :)

Cheers,
Gavin.



-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
