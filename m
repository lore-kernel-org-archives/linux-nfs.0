From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: slow create/delete performance
Date: Thu, 30 Oct 2003 16:28:06 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16288.41318.607973.261843@notabene.cse.unsw.edu.au>
References: <20031029152433.A1917@oppie.phys.uwm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AF5MG-0000rv-00
	for <nfs@lists.sourceforge.net>; Wed, 29 Oct 2003 21:28:32 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AF5Lv-0005LV-RX
	for nfs@lists.sourceforge.net; Wed, 29 Oct 2003 21:28:12 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <apgarcia@gravity.phys.uwm.edu>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Thu, 30 Oct 2003 16:28:06 +1100
To: Phil Garcia <apgarcia@gravity.phys.uwm.edu>
In-Reply-To: message from Phil Garcia on Wednesday October 29
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wednesday October 29, apgarcia@gravity.phys.uwm.edu wrote:
> Hi,
> 
> We've been running some benchmarks on both local and nfs mounts.  The
> read and write speeds are comparable, but creating and deleting small
> files is much slower over nfs than it is locally.  Is there a patch to
> fix this problem?
> 

No. This is the nature of NFS.  A file create must be synchronous with
the server.  Data writes don't (in NFSv3).

Creating lots of little files is *the* pathological case for NFS.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
