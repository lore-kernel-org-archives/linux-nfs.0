Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:9849 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955Ab0DKUuv convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Apr 2010 16:50:51 -0400
Subject: Re: BUG: cannot acquire lock twice with NFSv4
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Arnaud Giersch <arnaud.giersch@iut-bm.univ-fcomte.fr>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1270999493.4663.1.camel@localhost.localdomain>
References: <wwer5mo3hf9.fsf@powwow.iut-bm.univ-fcomte.fr>
	 <wwed3y73da5.fsf@powwow.iut-bm.univ-fcomte.fr>
	 <1270999493.4663.1.camel@localhost.localdomain>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 11 Apr 2010 16:50:30 -0400
Message-ID: <1271019030.2898.1.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, 2010-04-11 at 11:24 -0400, Trond Myklebust wrote: 
> On Sat, 2010-04-10 at 10:46 +0200, Arnaud Giersch wrote: 
> > Vendredi 09 avril 2010, vers 15:05:14 (+0200), j'ai écrit :
> > 
> > >   1. opens a first file, and acquires read lock on it ;
> > >   2. opens a second file, and acquires read lock on it ;
> > >   3. releases locks, and closes files.
> > >
> > > Both opened files are of course on the NFS mount.  On the first run, all
> > > seems to be fine.  On the second (and subsequent) runs, the lock is
> > > refused at step 2 with errno=37 (ENOLCK, No locks available).
> > 
> > I noticed that things appear to work as expected if commit
> > 8e469ebd6dc32cbaf620e134d79f740bf0ebab79 (NFSv4: Don't allow posix
> > locking against servers that don't support it) is reverted.
> > 
> > From what I can see, the client is granted a read delegation for the
> > second file.  On the second run, the client fetches some cached state
> > for this file.
> > 
> > On this second run, state->flags (as in _nfs4_do_open, or in
> > nfs4_proc_lock) only contains NFS_DELEGATED_STATE, while on the first
> > run, it also contained NFS_O_RDONLY_STATE and NFS_STATE_POSIX_LOCKS.
> 
> Ah. Nice catch! That does indeed need to be fixed... I'll draft up a
> patch tomorrow, and send you a copy.
> 
> Cheers
>   Trond

How about the following?

Cheers
  Trond
----------------------------------------------------------------------------------------------- 
NFSv4: fix delegated locking

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Arnaud Giersch reports that NFSv4 locking is broken when we hold a
delegation since commit 8e469ebd6dc32cbaf620e134d79f740bf0ebab79 (NFSv4:
Don't allow posix locking against servers that don't support it).

According to Arnaud, the lock succeeds the first time he opens the file
(since we cannot do a delegated open) but then fails after we start using
delegated opens.

The following patch fixes it by ensuring that locking behaviour is
governed by a per-filesystem capability flag that is initially set, but
gets cleared if the server ever returns an OPEN without the
NFS4_OPEN_RESULT_LOCKTYPE_POSIX flag being set.

Reported-by: Arnaud Giersch <arnaud.giersch@iut-bm.univ-fcomte.fr>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    3 ++-
 fs/nfs/nfs4proc.c         |    4 +++-
 include/linux/nfs_fs_sb.h |    1 +
 3 files changed, 6 insertions(+), 2 deletions(-)


diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 2a3d352..a8766c4 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1294,7 +1294,8 @@ static int nfs4_init_server(struct nfs_server *server,
 
 	/* Initialise the client representation from the mount data */
 	server->flags = data->flags;
-	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR;
+	server->caps |= NFS_CAP_ATOMIC_OPEN|NFS_CAP_CHANGE_ATTR|
+		NFS_CAP_POSIX_LOCK;
 	server->options = data->options;
 
 	/* Get a client record */
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fe0cd9e..6380670 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1523,6 +1523,8 @@ static int _nfs4_proc_open(struct nfs4_opendata *data)
 		nfs_post_op_update_inode(dir, o_res->dir_attr);
 	} else
 		nfs_refresh_inode(dir, o_res->dir_attr);
+	if ((o_res->rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) == 0)
+		server->caps &= ~NFS_CAP_POSIX_LOCK;
 	if(o_res->rflags & NFS4_OPEN_RESULT_CONFIRM) {
 		status = _nfs4_proc_open_confirm(data);
 		if (status != 0)
@@ -1664,7 +1666,7 @@ static int _nfs4_do_open(struct inode *dir, struct path *path, fmode_t fmode, in
 	status = PTR_ERR(state);
 	if (IS_ERR(state))
 		goto err_opendata_put;
-	if ((opendata->o_res.rflags & NFS4_OPEN_RESULT_LOCKTYPE_POSIX) != 0)
+	if (server->caps & NFS_CAP_POSIX_LOCK)
 		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
 	nfs4_opendata_put(opendata);
 	nfs4_put_state_owner(sp);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 717a5e5..e82957a 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -176,6 +176,7 @@ struct nfs_server {
 #define NFS_CAP_ATIME		(1U << 11)
 #define NFS_CAP_CTIME		(1U << 12)
 #define NFS_CAP_MTIME		(1U << 13)
+#define NFS_CAP_POSIX_LOCK	(1U << 14)
 

 /* maximum number of slots to use */

