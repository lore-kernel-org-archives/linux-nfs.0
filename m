From: Olaf Kirch <okir@suse.de>
Subject: Re: Force client page cache invalidation?
Date: Thu, 26 Feb 2004 09:57:18 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040226085718.GB1197@suse.de>
References: <403B9842.9070001@ibl.bm> <1145.130.128.48.179.1077653208.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: ralph gonzalez <rgonzale@ibl.bm>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwHMK-0001Pp-K9
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 00:59:08 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1AwH6y-0004yx-2L
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 00:43:16 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <1145.130.128.48.179.1077653208.squirrel@webmail.uio.no>
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

> Linux does not support this sort of kludge and is unlikely to do so for
> the near future. The VM simply cannot support it.

What about using fadvise(POSIX_FADV_DONTNEED) - shouldn't this
do the trick? Or does it refuse to invalidate mapped pages?

Olaf
-- 
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+ 


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
