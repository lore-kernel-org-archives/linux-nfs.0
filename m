From: Olaf Kirch <okir@suse.de>
Subject: Re: lockd / statd fun (sorry)
Date: Fri, 23 Apr 2004 13:57:04 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040423115702.GQ3491@suse.de>
References: <200404231137.29216.gdh@acentral.co.uk> <200404231332.07891.bernd-schubert@web.de> <200404231248.30956.gdh@acentral.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BGzIq-0003SS-M6
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 04:57:08 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BGzIq-0006HX-8k
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 04:57:08 -0700
To: Gavin Hamill <gdh@acentral.co.uk>
In-Reply-To: <200404231248.30956.gdh@acentral.co.uk>
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

On Fri, Apr 23, 2004 at 12:48:30PM +0100, Gavin Hamill wrote:
> OK, I did see your message in the archives, but wasn't sure that it was 
> relevant here (I'm getting error -13 when you got -5) but I'm game for a 
> laugh :)

13 is EACCESS, and is probably returned by statd. So I would say you
are able to talk to statd, only there's something wrong with the setup.

statd wants the following files available and writable:

/var/lib/nfs/state	(at start-up only; to store seq# number)
/var/lib/nfs/sm		to store the NFS peer's address
/var/lib/nfs/sm.bak	(at start-up only; for lock recovery)

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
