From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Marking inodes as stale can be wrong
Date: Thu, 29 Apr 2004 12:44:56 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1083257096.3686.27.camel@lade.trondhjem.org>
References: <20040429144012.GA15361@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BJEeh-00019L-F4
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 09:44:59 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BJEeh-0003gk-Ba
	for nfs@lists.sourceforge.net; Thu, 29 Apr 2004 09:44:59 -0700
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
> 	fh_verify did the subtree check, and found that
> 	~/Mail was mode 700, and hence user nobody didn't
> 	have x permissions on the directory. So it would
> 	return ESTALE to the client.

This is a bug!

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
