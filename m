From: "Irina Slutsky" <ira@ibrix.com>
Subject: RE: [PATCH] kNFSd - 2 of 7 - Revlaidate inodes after filehandle and name lookup in nfsd
Date: Tue, 17 Dec 2002 09:36:25 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <000201c2a5d9$adcec250$6902a8c0@Iralaptop>
References: <E18O714-0000ot-00@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "'Brian Dixon'" <dixonbp@us.ibm.com>,
   "'NeilBrown'" <neilb@cse.unsw.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail3.atl.registeredsite.com ([64.224.219.77] ident=nobody)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18OIpx-0004zT-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Dec 2002 06:36:46 -0800
To: <nfs@lists.sourceforge.net>
In-Reply-To: <E18O714-0000ot-00@notabene.cse.unsw.edu.au>
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

Thanks for this patch. Problem, this patch is addressing is very
important for me. This is the behaviors I am missing and is trying to
work around. When do you think this patch can be incorporated in the
official kernel release?

Small note: there is an inline routine 
do_reavlidate(struct denty *) in the kernel
that could be used instead. It has all the "if"s checking inside.

I also have a question on the same topic:

Is there any particular reason for not allowing a fs to create file
handle for exported entry? I know the code is easier this way, but it
would be very useful. 

Thanks
Irina Slutsky 


-----Original Message-----
From: nfs-admin@lists.sourceforge.net
[mailto:nfs-admin@lists.sourceforge.net] On Behalf Of NeilBrown
Sent: Monday, December 16, 2002 8:59 PM
To: Marcelo Tosatti
Cc: nfs@lists.sourceforge.net
Subject: [NFS] [PATCH] kNFSd - 2 of 7 - Revlaidate inodes after
filehandle and name lookup in nfsd



The patch was written by Marc Eshel and Frank Schmuck. 
It was received from  "Brian Dixon" <dixonbp@us.ibm.com>
though I changed it slightly.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    7 +++++++
 ./fs/nfsd/vfs.c   |   12 +++++++-----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2002-12-16 16:28:47.000000000 +1100
+++ ./fs/nfsd/nfsfh.c	2002-12-16 16:28:47.000000000 +1100
@@ -620,6 +620,13 @@ fh_verify(struct svc_rqst *rqstp, struct
 			switch (fh->fh_fileid_type) {
 			case 0:
 				dentry = dget(exp->ex_dentry);
+				/* need to revalidate the inode */
+				inode = dentry->d_inode;
+				if (inode->i_op &&
inode->i_op->revalidate)
+					if
(inode->i_op->revalidate(dentry)) {
+						dput(dentry);
+						dentry =
ERR_PTR(-ESTALE);
+					}
 				break;
 			default:
 				dentry =
find_fh_dentry(exp->ex_dentry->d_inode->i_sb,

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2002-12-16 16:28:47.000000000 +1100
+++ ./fs/nfsd/vfs.c	2002-12-16 16:28:47.000000000 +1100
@@ -168,11 +168,13 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			mntput(mnt);
 		}
 	}
-	/*
-	 * Note: we compose the file handle now, but as the
-	 * dentry may be negative, it may need to be updated.
-	 */
-	err = fh_compose(resfh, exp, dentry, fhp);
+
+	if (dentry->d_inode && dentry->d_inode->i_op &&
+	    dentry->d_inode->i_op->revalidate &&
+	    dentry->d_inode->i_op->revalidate(dentry))
+		err = nfserr_noent;
+	else
+		err = fh_compose(resfh, exp, dentry, fhp);
 	if (!err && !dentry->d_inode)
 		err = nfserr_noent;
 out:


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
