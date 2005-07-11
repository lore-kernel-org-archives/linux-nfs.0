From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH fs/locks 2 of 3] Use proper tgid in
	locks_remove_posix
Date: Mon, 11 Jul 2005 08:16:57 -0400
Message-ID: <1121084217.8204.52.camel@lade.trondhjem.org>
References: <20050711103250.GH27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DrxDo-0007Fa-I1
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:17:16 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DrxDo-0008VQ-4M
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 05:17:16 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711103250.GH27163@suse.de>
Sender: nfs-admin@lists.sourceforge.net
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

m=C3=A5 den 11.07.2005 Klokka 12:32 (+0200) skreiv Olaf Kirch:
> # Subject: [NFS] Use proper tgid in locks_remove_posix
> #=20
> # This patch fixes a problem with lost unlock calls in multithreaded
> # applications. locks_remove_posix would send a single unlock call with
> # the task group ID of the current process, which may not be the same as
> # the tgid of the lock. This patch ensures that we send separate unlock
> # calls for different fl_pid values.

This doesn't look right. Why should a thread be killing locks that
belong to a different process?

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
