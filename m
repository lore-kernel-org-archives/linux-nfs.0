From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: Busy inodes after unmount followed by Oops
Date: Fri, 21 May 2004 12:44:04 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085157843.3666.75.camel@lade.trondhjem.org>
References: <3FFE8B28.1E645E4E@moving-picture.com>
	 <40AE23DC.6C240DAE@moving-picture.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, autofs@linux.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BRD7v-0005nm-Dy
	for nfs@lists.sourceforge.net; Fri, 21 May 2004 09:44:07 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BRD7v-0003fa-3g
	for nfs@lists.sourceforge.net; Fri, 21 May 2004 09:44:07 -0700
To: James Pearson <james-p@moving-picture.com>
In-Reply-To: <40AE23DC.6C240DAE@moving-picture.com>
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

P=E5 fr , 21/05/2004 klokka 11:44, skreiv James Pearson:

> We've been running this patch on over 400 machines for the last 10 or so
> days, and have not seen any instance of this 'VFS: Busy inodes after
> unmount/Oops' problem above - previously, we would have seen a
> significant number of these in the same time scale (and we are still
> seeing the problem on machines not using the patch).

Note  that Greg's patch for solving the NFS client issues that were
revealed by this bug is in 2.4.26 (and in 2.6.5)...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
