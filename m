From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFSv4  and vi
Date: Thu, 19 Feb 2004 10:49:36 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040219154936.GA20586@fieldses.org>
References: <200402190958.38127.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AtqWE-0001d4-1I
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 07:55:18 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1AtqQo-0008Hc-Mk
	for nfs@lists.sourceforge.net; Thu, 19 Feb 2004 07:49:42 -0800
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
In-Reply-To: <200402190958.38127.vincent.roqueta@ext.bull.net>
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

On Thu, Feb 19, 2004 at 09:58:38AM +0100, Vincent ROQUETA wrote:
> Here are vi traces for opening "/mnt/nfs/vincent/suite-tests/toto3"

These bug reports are no help if you won't remind us, on each bug
report, which kernel you're using, with which (if any) patches.  Also,
it'd help if you could test with the latest CITI NFSv4 patches
(http://www.citi.umich.edu/projects/nfsv4/linux/).  I suspect the
problem you're seeing is a problem that's already fixed with those
patches.

--Bruce Fields


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
