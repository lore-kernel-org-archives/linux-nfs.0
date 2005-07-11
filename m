From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH fs/locks 2 of 3] Use proper tgid in locks_remove_posix
Date: Mon, 11 Jul 2005 15:16:39 +0200
Message-ID: <20050711131639.GU27163@suse.de>
References: <20050711103250.GH27163@suse.de> <1121084217.8204.52.camel@lade.trondhjem.org> <20050711124840.GR27163@suse.de> <1121086941.13326.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dry9L-0001jC-To
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:16:43 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Dry9L-0003aV-DU
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:16:43 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121086941.13326.14.camel@lade.trondhjem.org>
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

On Mon, Jul 11, 2005 at 09:02:21AM -0400, Trond Myklebust wrote:
> For posix locks we should pretty much be ignoring the value of fl_pid.
> It gets returned to the user in a F_GETLK call, but all the low-level
> functions (such as posix_same_owner) should be testing the value of
> fl_owner instead.
> 
> The exception here is nlmsvc_same_owner(), which has to follow the NLM
> byte range spec but doesn't rely on locks_remove_posix.

Let me try to explain this a little better. What I believe is happening
is that on the client, thread A with tgid 0xA establishes a lock,
and when thread B closes the file. locks_remove_posix sends an unlock request
to the server with tgid 0xB.

On the server, posix_lock_file walks the list of all existing locks,
comparing the lock owner via nlmsvc_same_owner - and since the fl_pid
value of the request is 0xB, this misses the established lock with
fl_pid == 0xA.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
