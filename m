From: Olaf Kirch <okir@suse.de>
Subject: Re: [sdg@dir.bg: Bug#239230: nfs-kernel-server: exportfs fails to export a dir with a ``#'' (pound sign) in name even when ``#'' is given as \043]
Date: Mon, 22 Mar 2004 10:53:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040322095358.GC11393@suse.de>
References: <20040321171325.GX29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B5M8B-0001RG-2K
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 01:54:03 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B5M89-0000wP-45
	for nfs@lists.sourceforge.net; Mon, 22 Mar 2004 01:54:01 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040321171325.GX29237@perlsupport.com>
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

On Sun, Mar 21, 2004 at 12:13:25PM -0500, Chip Salzenberg wrote:
> 	Blank  lines  are  ignored.  A pound sign ("#") introduces a comment to
> 	the end of the line.

So
	/weird-dir-# *(ro)
is parsed as
	/weird-dir-
which is an export to the whole wide world with default options.

He should try /weird-dir-\#

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
