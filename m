From: Neil Brown <neilb@suse.de>
Subject: flock and lockf over NFS and the 'pid' in lockd requests.
Date: Mon, 30 Apr 2007 11:45:39 +1000
Message-ID: <17973.19011.690165.95878@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiKxq-00037D-H4
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 18:46:08 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiKxr-0006KT-M6
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 18:46:09 -0700
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


Hi,
 I've been looking at a difficultly being experienced with procmail
 used over NFS.

 procmail (and I don't think it is alone in this) can be compiled to
 use multiple locking schemes (just in case).  So it might create a
 lock file, call flock, then get an fcntl lock on the file.

 For local filesystems, this works fine, as each of the locking
 domains are independent - an flock doesn't conflict with an fcntl
 lock on the same file.

 And it used to work over NFS, because flock didn't travel to the
 server, so the domains were again independent.

 But it doesn't work with recent kernels.
 Since about 2.6.12, flock calls on NFS have been sent over the
 network and become fcntl locks on the server (which is a little
 inconsistent, but understandable).

 This means that when procmail tries to take an flock and a fcntl
 lock, the server sees that the second one conflicts with the first,
 and procmail blocks.  No good.

 Now we could compile procmail (and any other mail program that does
 similar tricks) to only use one locking mechanism, but that isn't
 really very satisfactory I think.

 We cannot get the server to support two independent locking domains,
 so the only way this can be fixed is to not let the server see the
 conflict, and I believe this is possible.

 The current lockd code makes sure that it can get a local lock before
 asking for a remote lock.  If there is a local conflict, there is no
 point in asking the server.  This means that a lockd server will
 *never* see two locks from the one lockd client that conflict.  It
 may well see locks from two different clients that conflict (that is
 the whole point) but not two from the one client.

 Currently an flock and an fcntl lock on the one file will both be sent
 to the lockd server and it will appear to be a conflict.  We can tell
 lockd that it isn't a conflict by setting the 'pid' field in the lock
 requests to some constant (e.g. 0, or 42 or whatever).
 As no genuine conflicts are ever sent to a server, it is always safe
 to just send a constant pid.  The pid is only used for lockd to
 mediate locking requests between processes on the same client.  Now
 that the lockd client never depends on the server for that mediation,
 there is no need to send the pid.


 So I would like to propose the following patch.

 It is possible that the use of 'pid' in req->a_owner string (at top
 of the chunk in the patch) should be removed too, but that doesn't
 seem to be used (in the NFS server implementation at least) so I
 didn't need that removed for testing.

 Note too that if we drop the usage of 'pid' here, then there is a lot
 of code for generation unique pids that can be dropped as well.  So
 this isn't a complete patch, just the core idea.

Have I missed something important?  Can we really drop the pid?
If not, is there something else that can be done to make procmail work
other that requiring a recompile.

Thanks,
NeilBrown


diff .prev/fs/lockd/clntproc.c ./fs/lockd/clntproc.c
--- .prev/fs/lockd/clntproc.c	2007-04-30 10:41:01.000000000 +1000
+++ ./fs/lockd/clntproc.c	2007-04-30 11:10:08.000000000 +1000
@@ -134,7 +134,7 @@ static void nlmclnt_setlockargs(struct n
 	lock->oh.len  = snprintf(req->a_owner, sizeof(req->a_owner), "%u@%s",
 				(unsigned int)fl->fl_u.nfs_fl.owner->pid,
 				utsname()->nodename);
-	lock->svid = fl->fl_u.nfs_fl.owner->pid;
+	lock->svid = 42;
 	lock->fl.fl_start = fl->fl_start;
 	lock->fl.fl_end = fl->fl_end;
 	lock->fl.fl_type = fl->fl_type;



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
