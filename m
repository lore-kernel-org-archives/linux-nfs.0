From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: flock and lockf over NFS and the 'pid' in lockd requests.
Date: Sun, 29 Apr 2007 22:13:53 -0400
Message-ID: <1177899233.6400.58.camel@heimdal.trondhjem.org>
References: <17973.19011.690165.95878@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiLOn-0005Rc-7f
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 19:13:57 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1/211oXUgdtiEnYugOKUYTONxlmsfji7zs=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiLOp-0007LP-IV
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 19:13:59 -0700
In-Reply-To: <17973.19011.690165.95878@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-04-30 at 11:45 +1000, Neil Brown wrote:
>  Currently an flock and an fcntl lock on the one file will both be sent
>  to the lockd server and it will appear to be a conflict.  We can tell
>  lockd that it isn't a conflict by setting the 'pid' field in the lock
>  requests to some constant (e.g. 0, or 42 or whatever).
>  As no genuine conflicts are ever sent to a server, it is always safe
>  to just send a constant pid.  The pid is only used for lockd to
>  mediate locking requests between processes on the same client.  Now
>  that the lockd client never depends on the server for that mediation,
>  there is no need to send the pid.

??? On the contrary. Genuine conflicts are currently resolved by the
server and the server alone. We do admittedly call do_vfs_lock() with
the ACCESS flag set, but that doesn't set a lock. It is quite possible
for 2 processes to pass the do_vfs_lock() call, but then conflict on
actually setting the lock.

IOW: afaics your patch will fundamentally break posix/fcntl() locks.

Worse, it means that unlocking the flock() may result in an automatic
clearing of all posix/fcntl() locks...

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
