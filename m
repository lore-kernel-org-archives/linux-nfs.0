From: Olaf Hering <olh@suse.de>
Subject: Re: [PATCH fs/locks 2 of 3] Use proper tgid in locks_remove_posix
Date: Sat, 16 Jul 2005 17:15:27 +0200
Message-ID: <20050716151527.GA7726@suse.de>
References: <20050711103250.GH27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DtoO7-0001bZ-5I
	for nfs@lists.sourceforge.net; Sat, 16 Jul 2005 08:15:35 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DtoO5-0006U7-Jm
	for nfs@lists.sourceforge.net; Sat, 16 Jul 2005 08:15:35 -0700
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

 On Mon, Jul 11, Olaf Kirch wrote:

> # Subject: [NFS] Use proper tgid in locks_remove_posix
> # 
> # This patch fixes a problem with lost unlock calls in multithreaded
> # applications. locks_remove_posix would send a single unlock call with
> # the task group ID of the current process, which may not be the same as
> # the tgid of the lock. This patch ensures that we send separate unlock
> # calls for different fl_pid values.
> # 
> # Signed-off-by: Olaf Kirch <okir@suse.de>
> 
> Index: linux-2.6.12/fs/locks.c

This leads to glibc make check errors on ppc64:

cat /usr/src/packages/BUILD/glibc-2.3/cc-nptl/nptl/tst-cancel16.out
Timed out: killed the child process
1

tested with 2.6.13-rc3 and 'powerpc32 make check'


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
