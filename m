From: Olaf Kirch <okir@suse.de>
Subject: Re: Debian Bug#235886: nfs-kernel-server inducing load of 8-9 with no good reason for Linux 2.6 clients
Date: Fri, 19 Mar 2004 09:49:35 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040319084935.GB25649@suse.de>
References: <20040318210943.GK3605@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4FhD-0007yQ-20
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 00:49:39 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B4FhB-0006HX-8q
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 00:49:37 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040318210943.GK3605@perlsupport.com>
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

One more thing:

> Something is clearly wrong here; stopping nfs-kernel-server makes the
> load drop to zero almost immediately, and substituting nfs-user-server for
> nfs-kernel-server also fixes the problem.

This probably means the problem is in the NFSv3 client code. The major
difference between knfsd and unfsd is that the latter is v2 only.

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
