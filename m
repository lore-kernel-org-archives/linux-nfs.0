From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Marking inodes as stale can be wrong
Date: Thu, 29 Apr 2004 13:21:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083259309.3686.45.camel@lade.trondhjem.org>
References: <20040429144012.GA15361@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJFEN-0003qS-52
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 10:21:51 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BJFEM-0004O2-Rz
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 10:21:50 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040429144012.GA15361@suse.de>
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

On Thu, 2004-04-29 at 10:40, Olaf Kirch wrote:
> Hi,

>  -	nfs_revalidate_inode would do a GETATTR call to
>  	the server (running the 2.4.22 kernel), using
> 	uid 0.

Note: several of the nfs_file_*() functions call nfs_revalidate_inode(),
and they do so with task creds instead of using the actual credentials
in the struct file.

While I disagree that the client's interpretation of NFSERR_STALE is
incorrect, I do agree that using the wrong creds when revalidating an
open file is indeed a client bug, and should be fixed.

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
