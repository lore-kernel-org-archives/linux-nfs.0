From: "Chris Pascoe" <c.pascoe@itee.uq.edu.au>
Subject: Problem with patch-C-NfsdRevalidate
Date: Thu, 14 Nov 2002 10:34:15 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <006301c28b75$8f7e0370$47426682@itee.uq.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from gum.itee.uq.edu.au ([130.102.66.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18C7xg-000399-00
	for <nfs@lists.sourceforge.net>; Wed, 13 Nov 2002 16:34:24 -0800
To: <neilb@cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi Neil,

In
http://cgi.cse.unsw.edu.au/~neilb/patches/linux-stable/2.4.20-rc1/patch-C-Nf
sdRevalidate,
fh_compose may never be called and err will be left set to a dentry's
address or nfserr_acces (is that nfserr_acces ever used?) - if
dentry->d_inode/dentry->d_inode->i_op/dentry->d_inode->i_op->revalidate is
NULL.

Applying this patch results in problems with my Solaris clients, at least
when trying to create a new file or when trying to stat a nonexistent file
- output from truss:

open("/home/chrisp/a.lock.1036824940.2046.kauri", O_WRONLY|O_CREAT|O_EXCL,
0666) Err#-1057499168
lstat("/home/chrisp/a.lock", 0xFFBECFB8)  Err#-1071055655

If I arrange the tests as below, to call fh_compose even if we can't call
revalidate, all seems happy.  Is this behaviour correct?

--- vfs.c       2002/11/04 18:51:29     1.42
+++ vfs.c       2002/11/09 06:38:16
@@ -168,11 +168,13 @@
                        mntput(mnt);
                }
        }
-       /*
-        * Note: we compose the file handle now, but as the
-        * dentry may be negative, it may need to be updated.
-        */
-       err = fh_compose(resfh, exp, dentry, fhp);
+
+       if (dentry->d_inode && dentry->d_inode->i_op &&
+           dentry->d_inode->i_op->revalidate &&
+           dentry->d_inode->i_op->revalidate(dentry))
+               err = nfserr_noent;
+       else
+               err = fh_compose(resfh, exp, dentry, fhp);
        if (!err && !dentry->d_inode)
                err = nfserr_noent;
 out:

Regards,
Chris

--
Christopher Pascoe
IT Infrastructure Group Manager
School of Information Technology and Electrical Engineering
The University of Queensland   Brisbane  QLD  4072  Australia



-------------------------------------------------------
This sf.net email is sponsored by: Are you worried about 
your web server security? Click here for a FREE Thawte 
Apache SSL Guide and answer your Apache SSL security 
needs: http://www.gothawte.com/rd523.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
