From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux 2.6.10: locks are leaked
Date: Mon, 28 Mar 2005 19:34:28 -0500
Message-ID: <1112056468.10791.16.camel@lade.trondhjem.org>
References: <4248A080.2020600@gmx.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-VCWqaf/ZPuHvO23RolQF"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DG4gv-0005r0-QW
	for nfs@lists.sourceforge.net; Mon, 28 Mar 2005 16:34:45 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DG4gu-0006Ai-5P
	for nfs@lists.sourceforge.net; Mon, 28 Mar 2005 16:34:45 -0800
To: Peter Karl =?ISO-8859-1?Q?M=FCller?= <peter.karl.mueller@gmx.de>
In-Reply-To: <4248A080.2020600@gmx.de>
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


--=-VCWqaf/ZPuHvO23RolQF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

ty den 29.03.2005 Klokka 02:25 (+0200) skreiv Peter Karl M=FCller:
> Dear experts,
>=20
> my home directories are exported from server to client (both vanilla
> 2.6.10). When I start the famous "skype" program from my home directory
> in a console, enter my account/password, and then terminate the skype
> process by ctrl-\ some file locks remain on the server. These file
> locks prevent a successfull re-login after a re-launch of "skype"
> (you get "Logging in failed").
>=20
> I performed some tests with multiple running/stopped instances of
>=20
>       1 #include <stdio.h>
>       2 #include <sys/types.h>
>       3 #include <sys/stat.h>
>       4 #include <fcntl.h>
>       5 #include <signal.h>
>       6
>       7 int main ()
>       8 {
>       9    int fd =3D open ("DATAFILE", O_RDWR, 0600);
>      10    if (fd =3D=3D -1)
>      11       perror ("open"), exit (1);
>      12    printf ("file opened\n");
>      13    int rc =3D lockf (fd, F_LOCK, 0);
>      14    if (rc)
>      15       perror ("lockf"), exit (2);
>      16    printf ("lock acquired\n");
>      17    pid_t mypid =3D getpid ();
>      18    printf ("pid =3D %d\n", mypid);
>      19    sleep (10);
>      20    kill (mypid, 9);
>      21    return 0;
>      22 }
>=20
> and eventually ran into a well known kernel panic on the client. In two
> cases the server became fully inaccessible.
>=20

Please could you try to reproduce with 2.6.11? The latter contains the
well-known fix (i.e. the attached patch).

Cheers,
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-VCWqaf/ZPuHvO23RolQF
Content-Description: 
Content-Disposition: inline; filename=fix_locking_oops.dif
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/16 19:53:47-08:00 trond.myklebust@fys.uio.no 
#   [PATCH] Fix an Oopsable condition in the NFS locking
#   
#   Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
#   Signed-off-by: Linus Torvalds <torvalds@osdl.org>
# 
# fs/nfs/file.c
#   2005/01/16 16:00:00-08:00 trond.myklebust@fys.uio.no +8 -4
#   Fix an Oopsable condition in the NFS locking
# 
diff -Nru a/fs/nfs/file.c b/fs/nfs/file.c
--- a/fs/nfs/file.c	2005-03-28 19:33:22 -05:00
+++ b/fs/nfs/file.c	2005-03-28 19:33:22 -05:00
@@ -347,8 +347,10 @@
 static int do_setlk(struct file *filp, int cmd, struct file_lock *fl)
 {
 	struct inode *inode = filp->f_mapping->host;
+	sigset_t oldset;
 	int status;
 
+	rpc_clnt_sigmask(NFS_CLIENT(inode), &oldset);
 	/*
 	 * Flush all pending writes before doing anything
 	 * with locks..
@@ -362,7 +364,7 @@
 			status = filemap_fdatawait(filp->f_mapping);
 	}
 	if (status < 0)
-		return status;
+		goto out;
 
 	lock_kernel();
 	/* Use local locking if mounted with "-onolock" */
@@ -375,12 +377,12 @@
 		 * the process exits.
 		 */
 		if (status == -EINTR || status == -ERESTARTSYS)
-			posix_lock_file(filp, fl);
+			posix_lock_file_wait(filp, fl);
 	} else
 		status = posix_lock_file_wait(filp, fl);
 	unlock_kernel();
 	if (status < 0)
-		return status;
+		goto out;
 	/*
 	 * Make sure we clear the cache whenever we try to get the lock.
 	 * This makes locking act as a cache coherency point.
@@ -391,7 +393,9 @@
 	up(&inode->i_sem);
 	filemap_fdatawait(filp->f_mapping);
 	nfs_zap_caches(inode);
-	return 0;
+out:
+	rpc_clnt_sigunmask(NFS_CLIENT(inode), &oldset);
+	return status;
 }
 
 /*

--=-VCWqaf/ZPuHvO23RolQF--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
