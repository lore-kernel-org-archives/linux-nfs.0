From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS hang in 2.6.21.1
Date: Mon, 21 May 2007 12:56:14 -0400
Message-ID: <1179766574.6737.25.camel@heimdal.trondhjem.org>
References: <767985.78880.qm@web54407.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: John Frisk <john_a_frisk@yahoo.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HqBBJ-0005YB-24
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 09:56:25 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+kvVbluNEfUKVZuqDPOYn7BhsauPbjggY=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HqBBL-0004NY-M9
	for nfs@lists.sourceforge.net; Mon, 21 May 2007 09:56:28 -0700
In-Reply-To: <767985.78880.qm@web54407.mail.yahoo.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-05-21 at 07:18 -0700, John Frisk wrote:
> Team,
> I have been attempting to put together a linux HA NFS
> server for my home environment.  I am currently
> running two Debian etch 4.0 machines both running
> vanilla 2.6.21.1 kernels that I compiled (exception
> being the nvidia driver for video).  When I attempt to
> do some performance benchmarks, a test of bonnie++
> makes the NFS client stuck in a non-responsive
> non-killable state.  The NFS server at this point is
> not busy doing anything so I believe there may be some
> condition leading to a deadlock in the client. 

Could you please try the patches

http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-002-no_congestion_wait_in_update_request.dif
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-003-cleanup_coalesce.dif
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-004-cleanup_coalesce2.dif
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-005-cleanup_readpages.dif
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-006-fix_dirtying_race.dif
http://client.linux-nfs.org/Linux-2.6.x/2.6.21/linux-2.6.21-007-fix_page_overflow.dif

and

http://client.linux-nfs.org/Linux-2.6.x/2.6.22-rc2/linux-2.6.22-001-write_deadlock_avoidance.dif

That fixes all the write deadlock issues for me.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
