From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Support for cached lookups via readdirplus [5/6]
Date: Sun, 28 Jul 2002 17:26:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15684.3367.337559.979006@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel <linux-kernel@vger.kernel.org>,
    NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17YpwU-0005Pn-00
	for <nfs@lists.sourceforge.net>; Sun, 28 Jul 2002 08:26:46 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Enable lookups of negative dentries using READDIRPLUS.

If we find that the entire READDIR cache has been read, and we've seen
that no pages are missing, and that the EOF has been reached, then we
assume that the file does not exist.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.29-rdplus4/fs/nfs/dir.c linux-2.5.29-rdplus5/fs/nfs/dir.c
--- linux-2.5.29-rdplus4/fs/nfs/dir.c	Sat Jul 27 19:15:50 2002
+++ linux-2.5.29-rdplus5/fs/nfs/dir.c	Sat Jul 27 19:15:41 2002
@@ -614,9 +614,11 @@
 			d_add(dentry, inode);
 			nfs_renew_times(dentry);
 			error = 0;
+			goto out;
 		}
-		goto out;
-	}
+		nfs_zap_caches(dir);
+	} else if (error == -ENOENT)
+		goto no_entry;
 
 	error = NFS_PROTO(dir)->lookup(dir, &dentry->d_name, &fhandle, &fattr);
 	if (error == -ENOENT)
@@ -674,10 +676,10 @@
 	int res;
 
 	if (!NFS_USE_READDIRPLUS(dir))
-		return -ENOENT;
+		return -ENOTSUPP;
 	server = NFS_SERVER(dir);
 	if (server->flags & NFS_MOUNT_NOAC)
-		return -ENOENT;
+		return -EIO;
 	nfs_revalidate_inode(server, dir);
 
 	entry.fh = fh;
@@ -698,15 +700,19 @@
 		}
 		page_cache_release(page);
 
-		if (res == 0)
-			goto out_found;
-		if (res != -EAGAIN)
-			break;
+		switch (res) {
+		case 0:
+			fattr->timestamp = timestamp;
+			return 0;
+		case -ENOENT:
+			return -ENOENT;
+		case -EAGAIN:
+			continue;
+		default:
+		}
+		break;
 	}
-	return -ENOENT;
- out_found:
-	fattr->timestamp = timestamp;
-	return 0;
+	return -EIO;
 }
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
